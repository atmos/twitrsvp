require File.dirname(__FILE__)+'/../spec_helper'

describe "home page" do
  it "can view events" do
    login_quentin
    pp TwitRSVP::User.all

    user = TwitRSVP::User.first(:twitter_id => 1484261)
    9.times do |i|
      attendee = TwitRSVP::Attendee.gen(:user, :user_id => user.id)
      case i % 3
      when 1
        attendee.decline!
      when 2
        attendee.confirm!
      else
        pp attendee
      end
    end

    get '/'
    puts last_response.body
  end
end
