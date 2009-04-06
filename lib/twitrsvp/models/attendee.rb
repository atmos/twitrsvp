module TwitRSVP
  class Attendee
    class AttendeeDirectMessageError < StandardError; end

    include DataMapper::Resource
    INVITED   = 1
    DECLINED  = 3
    CONFIRMED = 5

    storage_names[:default] = 'twitrsvp_attendees'

    property :id, Serial
    property :user_id, Integer, :nullable => false
    property :event_id, Integer, :nullable => false
    property :status, Integer, :nullable => false, :default => INVITED
    property :notified, Boolean, :default => false

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
    after :create, :notify!

    def notify!
      TwitRSVP.retryable(:tries => 3) do
        dm = TwitRSVP::OAuth.consumer.request(:post, '/direct_messages/new.json', 
                                              event.user.access_token, {:scheme => :query_string},
                                              { :text => "#{event.description} - #{event.start_at.strftime('%a %b %e @ %l:%M %P')} http://twitrsvp.com",
                                                :user => user.twitter_id })
        case dm
        when Net::HTTPSuccess, Net::HTTPForbidden # success or denied, retry timeouts
          self.notified = true
          save
        else
          TwitRSVP::Log.logger.info("#{dm.inspect} => #{event.user.inspect} => #{user.inspect}")
          raise AttendeeDirectMessageError.new(user.twitter_id)
        end
      end
      true
    rescue AttendeeDirectMessageError => e
      TwitRSVP::Log.logger.info("Unable to dm : #{user.twitter_id}")
    end
  end
end
