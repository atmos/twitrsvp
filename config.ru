ENV['RACK_ENV'] ||= 'development'
begin
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  require "rubygems"
  require "bundler"
  Bundler.setup
end
Bundler.require

$: << 'lib'

require 'twitrsvp'
require 'rack/hoptoad'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/twitrsvp')

use Rack::Session::Cookie, :key          => 'rack.session',
                           :domain       => 'twitrsvp.com',
                           :path         => '/',
                           :expire_after => 172800,
                           :secret       => ENV['TWIT_RSVP_SESSION_SECRET']

use Rack::Static, :urls => ["/css", "/img", "js", "500.html" ], :root => "public"
use Rack::Hoptoad, ENV['HOPTOAD_KEY']

run TwitRSVP::App
