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
    follow_redirect!

    last_response.should have_selector("ul")
    last_response.should have_selector("h1:contains('Pending')")
    last_response.should have_selector("h1:contains('Your Events:')")
    last_response.should have_selector("h1:contains('Going To:')")
  end
end
