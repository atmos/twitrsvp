require File.dirname(__FILE__) + '/../spec_helper'

describe "TwitRSVP::User" do
  before(:each) do
    @user = TwitRSVP::User.gen
  end

  it "should be valid" do
    @user.should be_valid
  end

  it "should be able to populate your token and secret after your user is created" do
    @user.token = nil
    @user.save

    @new_user = TwitRSVP::User.first(:twitter_id => @user.twitter_id)
    @new_user.token = /\w{16}/.gen
    @new_user.secret = /\w{16}/.gen 
    @new_user.save

    TwitRSVP::User.get(@new_user.id).token.should_not be_nil
  end

  describe "organizing events" do
    it "with a valid event address" do
      FakeWeb.register_uri(:any, %r!^http://maps.google.com!,
        [{:string => TwitRSVP::Fixtures.successful_google_response,   :status => ['200', 'OK']}])

      lambda do
        @user.organize(/\w{5,14}/.gen, /w{3,12}/.gen, '1535 Pearl St, Boulder, CO',
                     'a big shindig with beer and stuff', 'tomorrow night at 8', 
                     ['atmos', 'ubermajestix', '@aniero'])
      end.should change(@user.events, :size).by(1)
      event = @user.events.last
      event.longitude.should eql('-105.2751640')
      event.latitude.should eql('40.0188937')
    end

    it "with an invalid event address" do
      FakeWeb.register_uri(:any, %r!^http://maps.google.com!,
                           [{:string => TwitRSVP::Fixtures.unsuccessful_google_response, :status => ['401', 'Unauthorized']}])
      lambda do
        @user.organize(/\w{5,14}/.gen, /w{3,12}/.gen, '15359428972 Somefreakinroadgooglecantfind, nome, AK',
                     'a big shindig with beer and stuff', 'tomorrow night at 8', 
                     ['atmos', 'ubermajestix', '@aniero'])
      end.should change(@user.events, :size).by(1)
      event = @user.events.last
      event.longitude.should eql('')
      event.latitude.should eql('')
    end
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
