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
      throw(:halt, [302, {'Location' => '/signup'}, '']) unless session[:user_id]
    end

    helpers do
      def oauth_consumer
        ::TwitRSVP::OAuth.consumer
      end

      def current_user
        session[:user_id].nil? ? nil : ::TwitRSVP::User.get(session[:user_id])
      end

      def event_url(event)
        "/events/#{event.id}"
      end
    end

    error do
      TwitRSVP::Log.logger.info env['sinatra.error'].message
      haml :failed
    end

    post '/events/:id/confirm' do
      attendee = TwitRSVP::Attendee.first(:user_id => current_user.id, :event_id => params['id'])
      attendee.confirm!
      redirect event_url(attendee.event)
    end

    post '/events/:id/decline' do
      attendee = TwitRSVP::Attendee.first(:user_id => current_user.id, :event_id => params['id'])
      attendee.decline!
      redirect event_url(attendee.event)
    end

    get '/events/:id' do
      @event = TwitRSVP::Event.get(params['id'])
      throw(:halt, [401, "You aren't authorized to view this event"]) unless @event.authorized?(current_user)
      haml :event
    end

    delete '/events/:id' do
      @event = TwitRSVP::Event.get(params['id'])
      @event.attendees.each { |attendee| attendee.destroy }
      @event.destroy

      throw(:halt, [401, "You aren't authorized to delete this event"]) unless @event.user_id == current_user.id
      redirect '/'
    end

    get '/organize' do
      @event = Event.new
      haml :organize
    end

    post '/organize' do
      @event = current_user.organize(params['name'], params['place'], 
                                     params['starts_at'], params['ends_at'], 
                                     params['usernames'].split(','))

      @event.valid? ? redirect(event_url(@event)) : haml(:organize)
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
        @user = ::TwitRSVP::User.first_or_create(:twitter_id  => @user_info['id'])  # really wish first_or_create behaved sanely
        @user.name, @user.avatar  = @user_info['name'], @user_info['profile_image_url']
        @user.token, @user.secret = access_token.token, access_token.secret
        @user.url    = 'http://twitter.com/'+@user_info['screen_name']
        @user.save

        session[:user_id] = @user.id
        redirect '/'
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

    get '/' do
      if current_user
        @organized_events = current_user.events[0..5]
        @pending_events   = current_user.invited
        @declined_events  = current_user.declined
        @confirmed_events = current_user.confirmed
        haml :home
      else
        haml :about
      end
    end

    get '/about' do
      haml :about
    end
    
    get '/peace' do
      session.clear
      redirect '/'
    end
  end
end
