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
    property :utc_offset,  Integer, :nullable => false
    property :time_zone,   String, :nullable => true, :default => 'Mountain Time (US & Canada)'

    property :avatar, String, :length => 512, :default => 'http://static.twitter.com/images/default_profile_normal.png'

    timestamps :at

    has n, :events, :class_name => '::TwitRSVP::Event', 
           :child_key => [:user_id], :order => [:created_at.desc]
    has n, :invites, :class_name => '::TwitRSVP::Attendee', 
           :child_key => [:user_id], :order => [:status.asc]

    def organize(name, place, address, description, start_date, start_time, names)
      begin_time = Chronic.parse("#{start_date} at #{start_time}")
      event = self.events.create({:user_id => self.id,
                                  :name        => name, 
                                  :description => description,
                                  :place       => place, 
                                  :start_at    => begin_time.nil? ? nil : begin_time.utc,
                                  :address     => address})
      if event.valid?
        names.each do |invitee_name|
          next if invitee_name == screen_name
          invitee_name = invitee_name.strip.gsub(/^@/, '')
          next if invitee_name.blank?
          begin
            TwitRSVP.retryable(:times => 2) do 
              user = User.first(:name => invitee_name)
              user = User.create_twitter_user(invitee_name) if user.nil?
              event.attendees.create(:user_id => user.id, :dm_key => /\w{4}/.gen)
            end
          rescue TwitRSVP::User::UserCreationError => e
            TwitRSVP::Log.logger.info(e.message)
          end
        end
        event.attendees.create(:user_id => self.id,  :status => TwitRSVP::Attendee::CONFIRMED, :dm_key => /\w{4}/.gen)
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
      user.utc_offset, user.screen_name = user_info['utc_offset'], user_info['screen_name']
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
      Attendee.all(:user_id => id, :status => TwitRSVP::Attendee::CONFIRMED, :limit => limit, :order => [:created_at.desc]).map { |attendee| attendee.event  }
    end

    def each_direct_message(&block)
      TwitRSVP.retryable(:tries => 3) do
        messages = TwitRSVP::OAuth.consumer.request(:get, '/direct_messages.json', access_token, {:scheme => :query_string})
        case messages
        when Net::HTTPSuccess 
          JSON.parse(messages.body).each do |message|
            yield message if block_given?
          end
        else # will retry up to 3 times, logging the response each time
          TwitRSVP::Log.logger.info("Response: #{messages.code}, Something screwed up, hopefully a retry will fix it.")
          raise ArgumentError.new('Unable to retrieve direct messages')
        end
      end
    end

    def poll_direct_messages
      return if events.empty?
      now = Time.now.utc - 43200
      each_direct_message do |message|
        events.each do |event|
          next if event.start_at < now
          attendee = event.attendees.detect { |attendee| attendee if attendee.user.twitter_id == message['sender_id'] }
          if message['text'] =~ /^yes (\w{4})/i
            attendee.confirm! if attendee.dm_key == $1
          elsif message['text'] =~ /^no (\w{4})/i
            TwitRSVP::Log.logger.info("Response: #{attendee.inspect}, #{$1}")
          end
        end
      end
    end
    def self.handle_direct_message_replies
      User.all.each do |user| 
        begin
          user.poll_direct_messages
        rescue => e
          TwitRSVP::Log.logger.info("Unable to fetch direct messages for #{user.screen_name}(#{e.message})")
        end
      end
    end
  end
end
