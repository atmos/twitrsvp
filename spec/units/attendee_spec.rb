require File.dirname(__FILE__) + '/../spec_helper'

describe "TwitRSVP::Attendee" do
  before(:each) do
    @attendee = TwitRSVP::Attendee.gen(:standalone)
  end
  it "should be valid" do
    @attendee.should be_valid
  end
end
