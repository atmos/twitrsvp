module TwitRSVP
  class User
    include DataMapper::Resource

    property :id, Serial
    property :twitter_id, Integer, :nullable => false, :unique => true
    property :name, String
    property :token, String
    property :secret, String

    timestamps :at

    has n, :events, :class_name => '::TwitRSVP::Event', :child_key => [:user_id]

    def organize(name, place, map_link, end_time, start_time, ids)
      event = self.events.build({:user_id => self.id,
                                 :name     => name, 
                                 :place    => place, 
                                 :map_link => map_link,
                                 :end_at   => Chronic.parse(end_time), 
                                 :start_at => Chronic.parse(start_time)})
      if event.valid?
        ids.each do |idx|
          event.attendees.create(:user_id => idx)
        end
      end
    end
  end
end
