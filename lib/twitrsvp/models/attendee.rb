module TwitRSVP
  class Attendee
    include DataMapper::Resource
    INVITED   = 1
    DECLINED  = 3
    CONFIRMED = 5

    property :id, Serial
    property :user_id, Integer, :nullable => false
    property :event_id, Integer, :nullable => false
    property :status, Integer, :nullable => false, :default => INVITED

    timestamps :at
    belongs_to :user, :class_name => '::TwitRSVP::User', :child_key => [:user_id]
    belongs_to :event, :class_name => '::TwitRSVP::Event', :child_key => [:event_id]

    def confirm!
      self.status = CONFIRMED
      save
    end

    def decline!
      self.status = DECLINED
      save
    end
  end
end
