require File.dirname(__FILE__)+'/../spec_helper'

describe "deleting an event" do
  it "works for the owner of the event" do
    login_quentin

    user = TwitRSVP::User.first(:twitter_id => 1484261)
    event = TwitRSVP::Event.gen(:user_id => user.id)

    get '/'

    delete "/events/#{event.id}"
    last_response.headers['Location'].should eql("/")
  end
  it "fails unless you're the owner of the event" do
    login_quentin

    user = TwitRSVP::User.first(:twitter_id => 1484261)
    attendee = TwitRSVP::Attendee.gen(:user, :user_id => user.id)

    get '/'
    delete "/events/#{attendee.event_id}"
    last_response.status.should eql(401)
  end
end
