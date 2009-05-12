module TwitRSVP
  class Attendee
    include DataMapper::Resource
    INVITED      = 1
    DECLINED     = 3
    CONFIRMED    = 5
    UNAUTHORIZED = 7
    storage_names[:default] = 'twitrsvp_attendees'

    property :id,       Serial
    property :user_id,  Integer, :nullable => false
    property :event_id, Integer, :nullable => false
    property :status,   Integer, :nullable => false, :default => INVITED
    property :notified, Boolean, :default => false

    validates_is_unique :user_id, :scope => [:event_id]

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

    def dm_response(text)
      if text =~ /^yes (\w{4})/i
        confirm! if event.dm_key == $1
      elsif text =~ /^no (\w{4})/i
        decline! if event.dm_key == $1
      end
    end

    def notification_message
      "#{event.dm_description[0..50]}, #{event.tiny_url} or dm back with YES or NO followed by the event key '#{event.dm_key}'"
    end
    after :create, :notify!

    def notify!
      return if user.twitter_id == event.user.twitter_id
      event.user.direct_message(user, notification_message) do |dm|
        TwitRSVP::Log.logger.info(dm.inspect)
        case dm
        when Net::HTTPSuccess # message was delivered
          self.notified = true
          save
        when Net::HTTPForbidden 
          self.status = UNAUTHORIZED
          save
        else
          TwitRSVP::Log.logger.info("Malformed dm response")
        end
      end
    end
  end
end
