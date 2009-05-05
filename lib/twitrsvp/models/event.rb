module TwitRSVP
  class Event
    include DataMapper::Resource
    attr_accessor :start_time, :end_time
    storage_names[:default] = 'twitrsvp_events'

    property :id,          Serial
    property :name,        String, :nullable => false, :length => 64
    property :place,       String, :nullable => true,  :length => 2048
    property :address,     String, :nullable => true,  :length => 2048
    property :latitude,    String, :nullable => true,  :length => 16
    property :longitude,   String, :nullable => true,  :length => 16
    property :permalink,   String, :nullable => true,  :length => 64
    property :tiny_url,    String, :nullable => true,  :length => 32
    property :description, String, :nullable => true,  :length => 140
    property :start_at,    Time,   :nullable => false
    property :is_public,   Boolean, :default => false

    timestamps :at

    belongs_to :user, :class_Name => '::TwitRSVP::User', :child_key => [:user_id]
    has n, :attendees, :order => [:status.asc]

    before :save, :geocode
    before :create, :geocode
    before :create, :create_permalink

    def google_map_link
      address.nil? ? nil : "http://maps.google.com/maps?q=#{address.gsub(/\s/, '+')}"
    end

    def geocode
      self.longitude, self.latitude, self.address = TwitRSVP.geocode(address) if attribute_dirty?(:address)
    rescue OpenURI::HTTPError
      self.longitude = self.latitude = self.address = ''
    end

    def create_permalink
      self.permalink ||= ::UUID.random_create.to_s
      content = Curl::Easy.perform("http://tinyurl.com/api-create.php?url=http://twitrsvp.com/events/#{::URI.escape(permalink)}") do |curl|
        curl.timeout = 30
      end
      self.tiny_url  ||= content.body_str
    end

    def localtime
      user.tz.utc_to_local(start_at)
    end

    def invited
      Attendee.all(:event_id => id, :status => TwitRSVP::Attendee::INVITED, :order => [:created_at])
    end

    def declined
      Attendee.all(:event_id => id, :status => TwitRSVP::Attendee::DECLINED, :order => [:created_at])
    end

    def confirmed
      Attendee.all(:event_id => id, :status => TwitRSVP::Attendee::CONFIRMED, :order => [:created_at])
    end

    def short_name
      "#{name}, #{place}"
    end

    def authorized?(user)
      user_id == user.id || attendees.select { |attendee| attendee.user_id == user.id }
    end

    def start_time
      self.start_at = (Time.now.utc + 86400) if start_at.nil?
      localtime
    end

    def invite_users(users)
      users.each do |invitee_name|
        next if invitee_name == user.screen_name
        invitee_name = invitee_name.strip.gsub(/^@/, '')
        next if invitee_name.blank?
        begin
          TwitRSVP.retryable(:times => 2) do 
            user = User.first(:name => invitee_name)
            user = User.create_twitter_user(invitee_name) if user.nil?
            attendees.create(:user_id => user.id, :dm_key => /\w{4}/.gen)
          end
        rescue TwitRSVP::User::UserCreationError => e
          TwitRSVP::Log.logger.info(e.message)
        end
      end
    end
  end
end
