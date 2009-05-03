require File.dirname(__FILE__) + '/../spec_helper'

describe "TwitRSVP::Attendee" do
  before(:each) do
    @attendee = TwitRSVP::Attendee.gen(:standalone)
  end

  it "should be valid" do
    @attendee.should be_valid
  end

  it "should handle dm responses for rsvping yes" do
    text = "yEs #{@attendee.dm_key}"
    @attendee.dm_response(text)
    @attendee.status.should eql(TwitRSVP::Attendee::CONFIRMED)
  end

  it "should handle dm responses for rsvping no" do
    text = "No #{@attendee.dm_key}"
    @attendee.dm_response(text)
    @attendee.status.should eql(TwitRSVP::Attendee::DECLINED)
  end
end
