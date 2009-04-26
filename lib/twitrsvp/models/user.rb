module TwitRSVP
  class User
    include DataMapper::Resource
    class  UserCreationError < StandardError; end
    storage_names[:default] = 'twitrsvp_users'

    property :id, Serial
    property :twitter_id,  Integer, :nullable => false, :unique => true
    property :name,        String, :nullable => false
    property :token,       String
    property :secret,      String
    property :screen_name, String, :nullable => false
    property :location,    String, :nullable => true, :default => 'Unknown'
    property :time_zone,   String, :nullable => true, :default => 'Mountain Time (US & Canada)'

    property :avatar, String, :length => 512, :default => 'http://static.twitter.com/images/default_profile_normal.png'

    timestamps :at

    has n, :events, :class_name => '::TwitRSVP::Event', 
           :child_key => [:user_id], :order => [:created_at.desc]
    has n, :invites, :class_name => '::TwitRSVP::Attendee', 
           :child_key => [:user_id], :order => [:status.asc]

    def organize(name, place, address, description, start_time, names)
      event = self.events.create({:user_id => self.id,
                                  :name        => name, 
                                  :description => description,
                                  :place       => place, 
                                  :start_at    => Chronic.parse(start_time),
                                  :address     => address})
      if event.valid?
        names.each do |invitee_name|
          TwitRSVP.retryable(:times => 2) do 
            user = User.first(:name => invitee_name.strip!)
            user = User.create_twitter_user(invitee_name) if user.nil?
            event.attendees.create(:user_id => user.id)
          end
        end
        event.attendees.create(:user_id => self.id,  :status => TwitRSVP::Attendee::CONFIRMED)
      end
      event
    end

    def access_token
      ::OAuth::AccessToken.new(::TwitRSVP::OAuth.consumer, token, secret)
    end

    def self.create_twitter_user(twitter_id)
      content = Curl::Easy.perform("http://twitter.com/users/show/#{twitter_id}.json") do |curl|
        curl.timeout = 30
      end
      user_info = JSON.parse(content.body_str)
      raise UserCreationError.new("Unable to find '#{twitter_id}'") if(user_info['error'] == 'Not found')
      result = unless user_info['error']
        create_from_user_info(user_info)
      end
    rescue JSON::ParserError
      raise UserCreationError.new("Unable to find '#{twitter_id}'")
    end

    def self.create_from_user_info(user_info, access_token = nil)
      user = ::TwitRSVP::User.first_or_create(:twitter_id  => user_info['id'])  # really wish first_or_create behaved sanely
      user.name, user.avatar  = user_info['name'], user_info['profile_image_url']
      user.token, user.secret = access_token.token, access_token.secret unless access_token.nil?
      user.location, user.time_zone = user_info['location'], user_info['time_zone']
      user.screen_name = user_info['screen_name']
      user.save
      user
    end

    def url
      @url ||= "http://twitter.com/#{screen_name}"
    end

    def engagements
      invites.map { |invite| invite.event }
    end

    def invited(limit = 5)
      Attendee.all(:user_id => id, :status => TwitRSVP::Attendee::INVITED, :limit => limit, :order => [:created_at.desc]).map { |attendee| attendee.event }
    end

    def declined(limit = 5)
      Attendee.all(:user_id => id, :status => TwitRSVP::Attendee::DECLINED, :limit => limit, :order => [:created_at.desc]).map { |attendee| attendee.event }
    end

    def confirmed(limit = 5)
      Attendee.all(:user_id => id, :status => TwitRSVP::Attendee::CONFIRMED, :limit => limit, :order => [:created_at.desc]).map { |attendee| attendee.event }
    end

    def poll_direct_messages
      return if events.empty?
      last_event = events.last
      TwitRSVP.retryable(:tries => 3) do
        messages = TwitRSVP::OAuth.consumer.request(:get, '/direct_messages.json', access_token, {:scheme => :query_string})
        case messages
        when Net::HTTPSuccess 
          JSON.parse(message.body).each do |message|
            attendee = last_event.attendees.detect { |attendee| attendee if attendee.user.twitter_id == message['sender_id'] }
            if message['text'] =~ /^rsvp yes$/
              attendee.confirm!
            elsif message['text'] =~ /^rsvp no$/
              attendee.decline!
            end
          end
        else # will retry up to 3 times, logging the response each time
          TwitRSVP::Log.logger.info("Response: #{dm.code}, Something screwed up, hopefully a retry will fix it. #{event.user.twitter_id} inviting #{user.twitter_id}")
          raise ArgumentError.new('Unable to retrieve direct messages')
        end
      end
    end
  end
end
