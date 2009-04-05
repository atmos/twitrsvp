require File.dirname(__FILE__)+'/../spec_helper'

describe "viewing an event" do
  it "displays the event when the current_user is an attendee of the event" do
    login_quentin

    user = TwitRSVP::User.first(:twitter_id => 1484261)
    attendee = TwitRSVP::Attendee.gen(:user, :user_id => user.id)
    event = TwitRSVP::Event.get(attendee.event_id)

    get "/events/#{event.id}"
    last_response.should have_selector("h1.fancy:contains('#{event.description}')")
    last_response.should have_selector("h2.fancy")
    last_response.should have_selector("h3.fancy a[href='#{event.map_link}']:contains('Map Link')")
    last_response.should have_selector("ul.confirmed")
    last_response.should have_selector("ul.invited")
    last_response.should have_selector("ul.declined")
  end
end
