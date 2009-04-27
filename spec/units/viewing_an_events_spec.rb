require File.dirname(__FILE__)+'/../spec_helper'

describe "viewing an event" do
  before(:each) do
    login_quentin
  end
  it "displays the event when the current_user is an attendee of the event" do
    user = TwitRSVP::User.first(:twitter_id => 1484261)
    attendee = TwitRSVP::Attendee.gen(:user, :user_id => user.id)
    event = TwitRSVP::Event.get(attendee.event_id)

    get "/events/#{event.id}"
    last_response.should have_selector("h1:contains('#{event.description}')")
    last_response.should have_selector("h2")
    #last_response.should have_selector("ul.confirmed")
    last_response.should have_selector("ul")
    #last_response.should have_selector("ul.declined")
    last_response.should have_selector("form[action='/events/#{event.id}/confirm'] > input[type='submit']")
    last_response.should have_selector("form[action='/events/#{event.id}/decline'] > input[type='submit']")
  end

  it "displays the event after authenticating when the current_user is an attendee of the event" do
    get '/peace'

    user = TwitRSVP::User.first(:twitter_id => 1484261)
    attendee = TwitRSVP::Attendee.gen(:user, :user_id => user.id)
    event = TwitRSVP::Event.get(attendee.event_id)

    get "/events/#{event.id}"

    login_quentin
    follow_redirect!

    last_response.should have_selector("h1:contains('#{event.description}')")
    last_response.should have_selector("h2")
    #last_response.should have_selector("ul.confirmed")
    last_response.should have_selector("ul")
    #last_response.should have_selector("ul.declined")
    last_response.should have_selector("form[action='/events/#{event.id}/confirm'] > input[type='submit']")
    last_response.should have_selector("form[action='/events/#{event.id}/decline'] > input[type='submit']")
  end
end
