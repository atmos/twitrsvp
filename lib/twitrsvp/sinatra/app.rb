module TwitRSVP
  class App < Sinatra::Base
    set :views, File.dirname(__FILE__)+'/views'
    enable :sessions

    before do
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

    post '/events/:id/confirm' do
      attendee = TwitRSVP::Attendee.first(:user_id => current_user.id, :event_id => params['id'])
      attendee.confirm!
      redirect '/'
    end

    post '/events/:id/decline' do
      attendee = TwitRSVP::Attendee.first(:user_id => current_user.id, :event_id => params['id'])
      attendee.decline!
      redirect '/'
    end

    get '/events/:id' do
      @event = TwitRSVP::Event.get(params['id'])
      throw(:halt, [401, "You aren't authorized to view this event"]) unless @event.authorized?(current_user)
      haml :event
    end

    get '/organize' do
      @event = Event.new
      haml :organize
    end

    post '/organize' do
      @event = current_user.organize(params['name'], params['place'], 
                                     params['map_link'], params['starts_at'], 
                                     params['ends_at'], params['usernames'].split(','))

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
        @user = ::TwitRSVP::User.first_or_create({:twitter_id  => @user_info['id']}, {
                                                  :name        => @user_info['name'],
                                                  :token       => access_token.token,
                                                  :secret      => access_token.secret})
        session[:user_id] = @user.id
        redirect '/'
      else
        haml :failed
      end
    end

    get '/signup' do
      request_token = oauth_consumer.get_request_token
      session[:request_token] = request_token.token
      session[:request_token_secret] = request_token.secret
      redirect request_token.authorize_url
    end

    get '/' do
      @pending_events   = current_user.invited
      @declined_events  = current_user.declined
      @organized_events = current_user.events[0..5]
      @confirmed_events = current_user.confirmed
      haml :home
    end
  end
end
