require 'oauth'
require 'json'
require 'haml/util'
require 'haml/engine'
require 'curb'
require 'chronic'
require 'logger'
require 'nokogiri'
require 'uuidtools'
require 'open-uri'
require 'randexp'
require 'digest/sha1'

require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'sinatra/base'

root = File.dirname(__FILE__)
require root + '/twitrsvp/models/user'
require root + '/twitrsvp/models/event'
require root + '/twitrsvp/models/attendee'
require root + '/twitrsvp/app'
require root + '/twitrsvp/ext/tzinfo_timezone'

module TwitRSVP
  def self.app
    @app ||= Rack::Builder.new do
      run App
    end
  end

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
    raise OpenURI::HTTPError.new('Too Many Results', nil) if response.search('Placemark').size > 2
    coords =  response.search('Placemark').first.search("coordinates").inner_html.split(",")[0,2]
    coords << response.search('Placemark').first.search("address").inner_html
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

  def self.number_to_ordinal(num)
    num = num.to_i
    if (10...20)===num
      "#{num}th"
    else
      g = %w{ th st nd rd th th th th th th }
      a = num.to_s
      c=a[-1..-1].to_i
      a + g[c]
    end
  end

  def self.date_format(date)
    date.strftime('%Y/%m/%d')
  end

  def self.time_format(date)
    date.strftime('%l:%M %p')
  end
end
