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
  end
end
