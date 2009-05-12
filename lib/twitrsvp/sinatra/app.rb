module TwitRSVP
  class App < Sinatra::Base
    set :views, File.dirname(__FILE__)+'/views'
    enable :sessions
    enable :methodoverride

    before do
      next if request.path_info == '/'
      next if request.path_info == '/about'
      next if request.path_info == '/peace'
      next if request.path_info == '/signup'
      next if request.path_info == '/callback'
      next if request.path_info == '/application.js'
      next if request.path_info == '/favicon.ico'
      unless session[:user_id]
        session[:return_to] = request.path_info
        throw(:halt, [302, {'Location' => '/about'}, '']) 
      end
    end

    helpers do
      def oauth_consumer
        ::TwitRSVP::OAuth.consumer
      end

      def localtime(start_date, start_time)
        time_of_day = Time.parse(start_time)
        year, month, day = start_date.split('/')

        current_user.tz.local_to_utc(Time.local(year, month, day, time_of_day.hour, time_of_day.min))
      rescue => e
        nil
      end

      def current_user
        session[:user_id].nil? ? nil : ::TwitRSVP::User.get(session[:user_id])
      end

      def attendee_uninvite(attendee)
        "<a class='negative should_post' href='#{event_url(attendee.event, '/uninvite')}/#{attendee.id}'>[x]</a>"
      end

      def event_attendees_links(event)
        event.attendees.map do |attendee| 
          " <a href='#{attendee.user.url}'>@#{attendee.user.screen_name}</a> " + attendee_uninvite(attendee)
        end.join(',')
      end

      def event_url(event, suffix = nil)
        "/events/#{event.permalink}#{suffix}"
      end

      def prune_expired_events(events)
        limit = Time.now.utc - 43200
        events.sort { |a,b| a.start_at <=> b.start_at }.map { |event| event if event.start_at > limit }.compact
      end

      def number_to_ordinal(num)
        TwitRSVP.number_to_ordinal(num)
      end
    end

    error do
      TwitRSVP::Log.logger.info env['sinatra.error'].message
      haml :failed
    end

    post '/events/:event_id/uninvite/:attendee_id' do |event_id, attendee_id|
      event = TwitRSVP::Event.first(:permalink => event_id)
      throw(:halt, [401, "You aren't authorized to uninvite people to this event"]) unless event.user == current_user
      attendee = TwitRSVP::Attendee.first(:event_id => event.id, :id => attendee_id)
      attendee.destroy unless attendee.user == current_user
      redirect event_url(event, '/edit')
    end

    post '/events/:id/confirm' do |event_id|
      @event = TwitRSVP::Event.first(:permalink => event_id)
      attendee = TwitRSVP::Attendee.first(:user_id => current_user.id, :event_id => @event.id)
      attendee.confirm!
      redirect event_url(attendee.event)
    end

    post '/events/:id/decline' do |event_id|
      @event = TwitRSVP::Event.first(:permalink => event_id)
      attendee = TwitRSVP::Attendee.first(:user_id => current_user.id, :event_id => @event.id)
      attendee.decline!
      redirect event_url(attendee.event)
    end

    get '/events/:id/edit' do |event_id|
      @event = TwitRSVP::Event.first(:permalink => event_id)
      throw(:halt, [401, "You aren't authorized to view this event"]) unless @event.user == current_user
      @form_path = "/events/#{params['id']}"
      haml :organize
    end

    get '/events/:id' do |event_id|
      @event = TwitRSVP::Event.first(:permalink => event_id)
      @current_attendee = current_user == @event.user ? nil : @event.attendees.find { |attendee| attendee.user == current_user }
      @page_title = @event.short_name
      throw(:halt, [401, "You aren't authorized to view this event"]) unless @event.authorized?(current_user)
      haml :event
    end

    delete '/events/:id' do |event_id|
      @event = TwitRSVP::Event.first(:permalink => event_id)
      throw(:halt, [401, "You aren't authorized to delete this event"]) unless @event.user_id == current_user.id
      @event.attendees.each { |attendee| attendee.destroy }
      @event.destroy
      redirect '/'
    end

    put '/events/:event_id' do |event_id|
      @event = TwitRSVP::Event.first(:permalink => event_id)
      @event.update_attributes(:name => params['name'], :place => params['place'], :address => params['address'],
                               :description => params['description'], 
                               :start_at => localtime(params['start_date'], params['start_time']))
      @event.invite_users(params['usernames'].split(','))
      @form_path = event_url(@event)
      @event.errors.any? ? haml(:organize) : redirect(event_url(@event))
    end

    post '/events' do
      @event = current_user.organize(params['name'], params['place'], params['address'], params['description'],
                                     localtime(params['start_date'], params['start_time']), params['usernames'].split(','))

      @event.errors.any? ? haml(:organize) : redirect(event_url(@event))
    end

    get '/schedule' do
      @page_title = "Create a new Event"
      @event = current_user.events.build(:start_at => Time.now.utc + 7200)
      haml(:organize)
    end

    get '/callback' do
      @request_token = ::OAuth::RequestToken.new(oauth_consumer,
                                                 session[:request_token],
                                                 session[:request_token_secret])

      access_token = @request_token.get_access_token

      oauth_response = oauth_consumer.request(:get, '/account/verify_credentials.json',
                                              access_token, { :scheme => :query_string })
      case oauth_response
      when Net::HTTPSuccess
        @user_info = JSON.parse(oauth_response.body)
        @user = ::TwitRSVP::User.create_from_user_info(@user_info, access_token)

        session[:user_id] = @user.id
        new_path = session.delete(:return_to) || '/'
        redirect new_path
      else
        raise ArgumentError.new('Unhandled HTTP Response')
      end
    end

    get '/signup' do
      TwitRSVP.retryable(:times => 2) do 
        request_token = oauth_consumer.get_request_token
        session[:request_token] = request_token.token
        session[:request_token_secret] = request_token.secret
        redirect request_token.authorize_url
      end
    end

    get '/declined' do
      @declined_events  = current_user.declined(100)
      haml :declined
    end

    get '/manage' do
      @event = Event.new
      @organized_events = prune_expired_events(current_user.events)[0..5]
      @pending_events   = prune_expired_events(current_user.invited)
      @declined_events  = prune_expired_events(current_user.declined)
      @confirmed_events = prune_expired_events(current_user.confirmed)
      haml :home
    end

    get '/about' do
      haml :about
    end

    get '/peace' do
      session.clear
      redirect '/'
    end

    get '/' do
      current_user ? redirect('/manage') : haml(:about)
    end
  end
end
