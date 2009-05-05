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
require 'logger'
gem 'nokogiri'
require 'nokogiri'
gem 'uuidtools'
require 'uuidtools'
require 'open-uri'
gem 'randexp'
require 'randexp'

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
require root + '/twitrsvp/ext/tzinfo_timezone'

module TwitRSVP
  module Log
    def self.logger
      if @logger.nil?
        @logger        = Logger.new("twitrsvp.log")
        @logger.level  = Logger::INFO 
      end
      @logger
    end
  end

  module OAuth
    def self.consumer
      ::OAuth::Consumer.new(ENV['TWIT_RSVP_READKEY'],
                            ENV['TWIT_RSVP_READSECRET'],
                            {:site => 'http://twitter.com'})
    end
  end

  def self.geocode(address)
    response = Nokogiri::XML(open("http://maps.google.com/maps/geo?q=#{URI.escape(address)}&output=xml&key=&oe=utf-8"))
    status =  response.search("code").inner_html
    raise OpenURI::HTTPError.new('Bad Response', nil) unless status == '200'
    coords =  response.search("coordinates").inner_html.split(",")[0,2]
    coords << response.search("address").inner_html
    return coords
  end

  def self.retryable(options = {}, &block)
    opts = { :tries => 1, :on => StandardError }.merge(options)
    retry_exception, retries = opts[:on], opts[:tries]

    begin
      return yield
    rescue retry_exception
      retry if (retries -= 1) > 0
    end
    yield
  end

  def self.date_format(date)
    date.strftime('%Y/%m/%d')
  end

  def self.time_format(date)
    date.strftime('%l:%M %p')
  end
end
