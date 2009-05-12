require File.dirname(__FILE__)+'/../spec_helper'

describe "viewing an event" do
  before(:each) do
    login_quentin
  end
  it "displays the event when the current_user is an attendee of the event" do
    user = TwitRSVP::User.first(:twitter_id => 1484261)
    attendee = TwitRSVP::Attendee.gen(:user, :user_id => user.id)
    event = TwitRSVP::Event.get(attendee.event_id)

    get "/events/#{event.permalink}"
    last_response.should have_selector("p:contains('#{event.description}')")
    last_response.should have_selector("#events #going")
    last_response.should have_selector("#events #not_going")
    last_response.should have_selector("#events #right_events")
  end

  it "displays the event after authenticating when the current_user is an attendee of the event" do
    get '/peace'

    user = TwitRSVP::User.first(:twitter_id => 1484261)
    attendee = TwitRSVP::Attendee.gen(:user, :user_id => user.id)
    event = TwitRSVP::Event.get(attendee.event_id)

    get "/events/#{event.permalink}"

    last_response.should have_selector("p:contains('#{event.description}')")
  end
end
