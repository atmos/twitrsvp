module TwitRSVP
  class User
    include DataMapper::Resource

    property :id, Serial
    property :twitter_id, Integer, :nullable => false, :unique => true
    property :name, String
    property :token, String
    property :secret, String

    timestamps :at
  end
end
