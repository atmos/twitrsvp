twitrsvp
========
Another [oauth][oauth] experiment.  Organize folks with [sinatra][sinatra] and [twitter][twitter].  Try it out on [TwitRSVP][twitrsvp].

Installation
============
It's a sinatra app, packaged as a gem, deployed as a rack app.

    % rake repackage
    % sudo gem install pkg/twitrsvp*.gem

Your basic deps look like this:
    
    % git clone git://github.com/wycats/bundler.git
    % cd bundler
    % rake repackage
    % sudo gem install pkg/*.gem
    % hash -r
    % gem_bundler

Deployment
==========
Use [passenger][passenger] and a config.ru like this:

Example config.ru

    require 'rubygems'
    require 'twitrsvp'

    DataMapper.setup(:default, "mysql://atmos:s3cr3t@localhost/twitrsvp_production")

    ENV['TWIT_RSVP_READKEY'] = /\w{18}/.gen  # this should really be what twitter gives you
    ENV['TWIT_RSVP_READSECRET'] = /\w{24}/.gen # this should really be what twitter gives you

    class TwitRSVPSite < TwitRSVP::App
      set :public,      File.expand_path(File.dirname(__FILE__), "public")
      set :environment, :production
    end

    run TwitRSVPSite

testing
=======

Just run rake...

[sinatra]: http://www.sinatrarb.com
[twitrsvp]: http://twitrsvp.com
[twitter]: http://twitter.com
[oauth]: http://oauth.net
[passenger]: http://modrails.com
