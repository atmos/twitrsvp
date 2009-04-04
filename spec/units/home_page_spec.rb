require File.dirname(__FILE__)+'/../spec_helper'

describe "home page" do
  it "can view events" do
    login_quentin

    user = TwitRSVP::User.first(:twitter_id => 1484261)
    9.times do |i|
      attendee = TwitRSVP::Attendee.gen(:user, :user_id => user.id)
      case i % 3
      when 1
        attendee.decline!
      when 2
        attendee.confirm!
      else
        #pp attendee
      end
    end

    get '/'
    last_response.should have_selector("h1.fancy:contains('Pending')")
    last_response.should have_selector("ul.pending")
    last_response.should have_selector("h1.fancy:contains('Accepted')")
    last_response.should have_selector("ul.accepted")
    last_response.should have_selector("h1.fancy:contains('Declined')")
    last_response.should have_selector("ul.declined")
  end
end
