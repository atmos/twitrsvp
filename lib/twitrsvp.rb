gem 'oauth'
require 'oauth'
gem 'json'
require 'json'
gem 'haml', '~>2.0.9'
require 'haml/util'
require 'haml/engine'
gem 'chronic'
require 'chronic'
gem 'curb'
require 'curb'

gem 'data_objects', '~>0.9.11'
gem 'dm-core', '~>0.9.10'
gem 'dm-types', '~>0.9.10'
gem 'dm-validations', '~>0.9.10'
gem 'dm-timestamps', '~>0.9.10'
require 'dm-core'
require 'dm-types'
require 'dm-validations'
require 'dm-timestamps'
require 'sinatra/base'

root = File.dirname(__FILE__)
require root + '/twitrsvp/models/user'
require root + '/twitrsvp/models/event'
require root + '/twitrsvp/models/attendee'
require root + '/twitrsvp/sinatra/app'

module TwitRSVP
  module OAuth
    def self.consumer
      ::OAuth::Consumer.new(ENV['TWIT_RSVP_READKEY'],
                            ENV['TWIT_RSVP_READSECRET'],
                            {:site => 'http://twitter.com'})
    end
  end
end
