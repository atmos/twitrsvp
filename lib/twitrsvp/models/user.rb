module TwitRSVP
  class User
    include DataMapper::Resource
    class  UserCreationError < StandardError; end
    storage_names[:default] = 'twitrsvp_users'

    property :id, Serial
    property :twitter_id, Integer, :nullable => false, :unique => true
    property :name, String
    property :token, String
    property :secret, String

    property :url, String, :length => 512
    property :avatar, String, :length => 512, :default => 'http://static.twitter.com/images/default_profile_normal.png'

    timestamps :at

    has n, :events, :class_name => '::TwitRSVP::Event', 
           :child_key => [:user_id], :order => [:created_at.desc]
    has n, :invites, :class_name => '::TwitRSVP::Attendee', 
           :child_key => [:user_id], :order => [:status.asc]

    def organize(name, place, description, start_time, names)
      event = self.events.create({:user_id => self.id,
                                  :name        => name, 
                                  :description => description,
                                  :place       => place, 
                                  :start_at    => Chronic.parse(start_time)})
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
        self.first_or_create({:twitter_id => user_info['id']},{
                              :name       => user_info['name'],
                              :avatar     => user_info['profile_image_url'],
                              :url        => 'http://twitter.com/'+user_info['screen_name']})
      end
    rescue JSON::ParserError
      raise UserCreationError.new("Unable to find '#{twitter_id}'")
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
  end
end
