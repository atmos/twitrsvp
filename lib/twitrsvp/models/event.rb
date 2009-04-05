module TwitRSVP
  class Event
    include DataMapper::Resource
    attr_accessor :start_time, :end_time
    storage_names[:default] = 'twitrsvp_events'

    property :id,       Serial
    property :name,     String, :nullable => false
    property :place,    String
    property :end_at,   Time, :nullable => false
    property :start_at, Time, :nullable => false
    property :map_link, String, :nullable => false, :length => 2048

    timestamps :at

    belongs_to :user, :class_Name => '::TwitRSVP::User', :child_key => [:user_id]
    has n, :attendees, :order => [:status.asc]

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
      "#{name} at #{place}"
    end

    def authorized?(user)
      user_id == user.id || attendees.select { |attendee| attendee.user_id == user.id }
    end
  end
end
