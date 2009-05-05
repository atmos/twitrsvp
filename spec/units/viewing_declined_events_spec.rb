require File.dirname(__FILE__)+'/../spec_helper'

describe "viewing decilned events" do
  before(:each) do
    login_quentin
  end
  it "displays the event when the current_user is an attendee of the event" do
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

    get '/declined'
    last_response.should have_selector("#pending h1.pending_header:contains('Declined')")
  end
end
