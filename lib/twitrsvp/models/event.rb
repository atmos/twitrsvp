module TwitRSVP
  class Event
    include DataMapper::Resource
    attr_accessor :start_time, :end_time

    property :id, Serial
    property :name, String, :nullable => false
    property :end_at,   Time, :nullable => false
    property :start_at, Time, :nullable => false
    property :map_link, String, :nullable => false, :length => 2048

    timestamps :at

    belongs_to :user, :class_Name => '::TwitRSVP::User', :child_key => [:user_id]
    has n, :attendees

    before :valid?, :set_event_times

    def set_event_times
      self.end_at = Chronic.parse(end_time)
      self.start_at = Chronic.parse(start_time)
    end
  end
end
