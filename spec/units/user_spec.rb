require File.dirname(__FILE__) + '/../spec_helper'

describe "TwitRSVP::User" do
  before(:each) do
    @user = TwitRSVP::User.gen
  end
  it "should be valid" do
    @user.should be_true
  end
end
