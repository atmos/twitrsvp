require File.dirname(__FILE__) + '/../spec_helper'

describe "TwitRSVP::User" do
  before(:each) do
    @user = TwitRSVP::User.gen
  end

  it "should be valid" do
    @user.should be_valid
  end

  it "can organize events" do
    mountain_sun = 'http://maps.google.com/maps?client=safari&oe=UTF-8&ie=UTF8&cid=0,0,18084609897785609242&fb=1&split=1&gl=us&dq=mountain+sun+boulder&daddr=1535+Pearl+St,+Boulder,+CO+80302&geocode=7476258840704006059,40.018911,-105.275170&ei=BqHVSYagIZa6sgPpzumvCg&z=16'

    lambda do
      @user.organize(/\w{5,14}/.gen, /w{3,12}/.gen, mountain_sun,
                   'tomorrow night at 8', 'tomorrow night at 11',
                   ['atmos', 'ubermajestix'])
    end.should change(@user.events, :size).by(1)
  end

  it "can return a list of their engagements" do
    3.times do
      TwitRSVP::Attendee.gen(:user, :user_id => @user.id)
    end
    @user.should have(3).engagements
  end

  it "can cache user info from twitter given a username" do
    user = ::TwitRSVP::User.create_twitter_user('atmos')
    user.url.should eql('http://twitter.com/atmos')
    user.avatar.should_not be_nil
  end

  it "raises errors when its unable to create from twitter given a bad username" do
    lambda { ::TwitRSVP::User.create_twitter_user(/\w{16}/.gen) }.should raise_error(TwitRSVP::User::UserCreationError)
  end
end
