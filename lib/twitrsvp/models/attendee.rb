module TwitRSVP
  class Attendee
    include DataMapper::Resource
    INVITED   = 1
    DECLINED  = 3
    CONFIRMED = 5

    storage_names[:default] = 'twitrsvp_attendees'

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
    after :create, :notify!

    def notify!
      dm = TwitRSVP::OAuth.consumer.request(:post, '/direct_messages/new.json', 
                                            event.user.access_token, {:scheme => :query_string},
                                            { :text => "#{event.description} - #{event.start_at.strftime('%a %b %e @ %l:%M %P')} http://twitrsvp.com",
                                              :user => user.twitter_id })
      TwitRSVP::Log.logger.info("#{dm.inspect} => #{event.user.inspect} => #{user.inspect}")
      true
    end
  end
end
