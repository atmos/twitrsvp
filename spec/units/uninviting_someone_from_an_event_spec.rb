require File.dirname(__FILE__)+'/../spec_helper'

describe "uninviting someone from an event" do
  before(:each) do
    login_quentin
  end
  it "displays the event when the current_user is an attendee of the event" do
    user = TwitRSVP::User.first(:twitter_id => 1484261)
    event = TwitRSVP::Event.gen(:user_id => user.id)

    attendee = event.attendees.first
    get "/events/#{event.permalink}"
    last_response.status.should eql(200)

    post "/events/#{event.permalink}/uninvite/#{attendee.id}"
    last_response.headers['Location'].should eql("/events/#{event.permalink}/edit")
  end
end
