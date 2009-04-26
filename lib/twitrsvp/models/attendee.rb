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
                                              { :text => "#{event.short_name} - #{event.start_at.strftime('%a %b %e @ %l:%M %P')} : dm back with 'rsvp yes', 'rsvp no' or visit #{event.tiny_url}",
                                                :user => user.twitter_id })
        case dm
        when Net::HTTPSuccess # message was delivered
          self.notified = true
          save
        when Net::HTTPForbidden 
          TwitRSVP::Log.logger.info("Response: #{dm.code}, #{user.name} probably doesn't follow #{event.user.name}.  http://doesfollow.com/#{user.name}/#{event.user.name}")
          raise AttendeeDirectMessageError.new(user.twitter_id)
        else # will retry up to 3 times, logging the response each time
          TwitRSVP::Log.logger.info("Response: #{dm.code}, Something screwed up, hopefully a retry will fix it. #{event.user.twitter_id} inviting #{user.twitter_id}")
          raise AttendeeDirectMessageError.new(user.twitter_id)
        end
      end
      true
    rescue AttendeeDirectMessageError => e
      TwitRSVP::Log.logger.info("Unable to dm : #{user.twitter_id}")
    end
  end
end
