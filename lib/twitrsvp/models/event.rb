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

    property :description, String, :nullable => false, :length => 140
    property :start_at,    Time,   :nullable => false

    timestamps :at

    belongs_to :user, :class_Name => '::TwitRSVP::User', :child_key => [:user_id]
    has n, :attendees, :order => [:status.asc]

    before :create, :geocode

    attr :address

    def geocode
      self.longitude, self.latitude, self.address = TwitRSVP.geocode(address) unless address.nil?
    rescue OpenURI::HTTPError
      self.longitude = self.latitude = self.address = ''
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

    def description
      "#{name}, #{place}"
    end

    def authorized?(user)
      user_id == user.id || attendees.select { |attendee| attendee.user_id == user.id }
    end
  end
end
