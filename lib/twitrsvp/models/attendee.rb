module TwitRSVP
  class Attendee
    include DataMapper::Resource

    property :id, Serial
    property :user_id, Integer, :nullable => false
    property :event_id, Integer, :nullable => false

    timestamps :at
    belongs_to :user, :class_name => '::TwitRSVP::User', :child_key => [:user_id]
    belongs_to :event, :class_name => '::TwitRSVP::Event', :child_key => [:event_id]
  end
end
