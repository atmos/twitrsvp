module TwitRSVP
  class Event
    include DataMapper::Resource
    attr_accessor :start_time, :end_time
    storage_names[:default] = 'twitrsvp_events'

    property :id,          Serial
    property :name,        String,  :nullable => false, :length => 32
    property :place,       String,  :nullable => false, :length => 32
    property :address,     String,  :nullable => true,  :length => 2048
    property :latitude,    String,  :nullable => true,  :length => 16
    property :longitude,   String,  :nullable => true,  :length => 16
    property :permalink,   String,  :nullable => true,  :length => 64
    property :tiny_url,    String,  :nullable => true,  :length => 32
    property :description, String,  :nullable => true,  :length => 140
    property :start_at,    Time,    :nullable => false
    property :is_public,   Boolean, :default  => false
    property :dm_key,      String,  :nullable => false, :length => 4 

    timestamps :at

    belongs_to :user, :class_Name => '::TwitRSVP::User', :child_key => [:user_id]
    has n, :attendees, :order => [:status.asc]

    before :save, :geocode
    before :save, :create_permalink

    after  :update, :attendees_update

    def google_map_link
      return address if address.nil?
      case Addressable::URI.parse(address).scheme
      when 'http', 'https'
        address
      else
        "http://maps.google.com/maps?q=#{address.gsub(/\s/, '+')}"
      end
    end

    def geocode
      old_address = address
      self.longitude, self.latitude, self.address = TwitRSVP.geocode(address) if attribute_dirty?(:address)
      true
    rescue OpenURI::HTTPError => e
      if e.message == 'Too Many Results'
        errors.add(:address, "Too many results for this address")
        self.address = original_values[:location] || old_address
        false
      else
        self.longitude = self.latitude = ''
        self.address = old_address
        true
      end
    end

    def create_permalink
      self.permalink ||= ::UUID.random_create.to_s
      if self.tiny_url.blank?
        content = Curl::Easy.perform("http://tinyurl.com/api-create.php?url=http://twitrsvp.com/events/#{::URI.escape(permalink)}") do |curl|
          curl.timeout = 30
        end
        self.tiny_url  ||= content.body_str
      end
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

    def authorized?(authorized_user)
      user_id == authorized_user.id || attendees.select { |attendee| attendee.user_id == authorized_user.id }.any?
    end

    def start_time
      self.start_at = (Time.now.utc + 7200) if start_at.nil?
      localtime
    end

    def invite_users(users)
      if attendees.size + users.size < 20
        users.each do |invitee_name|
          invitee_name = invitee_name.strip.gsub(/^@/, '')
          next if invitee_name.blank? || invitee_name == user.screen_name
          begin
            TwitRSVP.retryable(:times => 2) do 
              user = User.first(:name => invitee_name)
              user = User.create_twitter_user(invitee_name) if user.nil?
              attendees.create(:user_id => user.id)
            end
          rescue TwitRSVP::User::UserCreationError => e
            TwitRSVP::Log.logger.info(e.message)
          end
        end
      else
        errors.add(:attendees, "20 User Limit Exceeded")
      end
    end

    def dm_description
      time_format = "#{localtime.strftime('%b')} #{TwitRSVP.number_to_ordinal(localtime.strftime('%e'))}"
      "#{name}-#{time_format}-#{localtime.strftime('%l:%M%P').strip} @#{place}"
    end

    def attendees_update
      return unless dirty_attributes.any?
      message = "UPDATE: #{dm_description}, #{tiny_url}"
      attendees.each do |attendee|
        user.direct_message(attendee.user, message) do |dm|
          case dm
          when Net::HTTPSuccess # message was delivered
            attendee.notified = true
            attendee.save 
          end
        end
      end
    end
  end
end
