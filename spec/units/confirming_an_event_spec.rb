require File.dirname(__FILE__)+'/../spec_helper'

describe "confirming an event" do
  it "works" do
    login_quentin

    user = TwitRSVP::User.first(:twitter_id => 1484261)
    3.times do |i|
      attendee = TwitRSVP::Attendee.gen(:user, :user_id => user.id)
      case i % 3
      when 1
        attendee.decline!
      when 2
        attendee.confirm!
      else
        @event_id = attendee.event_id
      end
    end

    get '/'

    post "/events/#{@event_id}/confirm"
    last_response.headers['Location'].should eql("/events/#{@event_id}")

    get '/'
    last_response.should have_selector("h3 > a[href='/events/#{@event_id}']")
  end
end
