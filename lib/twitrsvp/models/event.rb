module TwitRSVP
  class Event
    include DataMapper::Resource
    attr_accessor :start_time, :end_time

    property :id,       Serial
    property :name,     String, :nullable => false
    property :place,    String
    property :end_at,   Time, :nullable => false
    property :start_at, Time, :nullable => false
    property :map_link, String, :nullable => false, :length => 2048

    timestamps :at

    belongs_to :user, :class_Name => '::TwitRSVP::User', :child_key => [:user_id]
    has n, :attendees

    def self.invited(user_id, limit = 5)
      Attendee.all(:user_id => user_id, :status => TwitRSVP::Attendee::INVITED, :limit => limit, :order => [:created_at]).map { |attendee| attendee.event }
    end

    def self.declined(user_id, limit = 5)
      Attendee.all(:user_id => user_id, :status => TwitRSVP::Attendee::DECLINED, :limit => limit, :order => [:created_at]).map { |attendee| attendee.event }
    end

    def self.confirmed(user_id, limit = 5)
      Attendee.all(:user_id => user_id, :status => TwitRSVP::Attendee::CONFIRMED, :limit => limit, :order => [:created_at]).map { |attendee| attendee.event }
    end

    def description
      "#{name} at #{place}"
    end
  end
end
