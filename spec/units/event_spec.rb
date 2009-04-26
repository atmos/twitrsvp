require File.dirname(__FILE__) + '/../spec_helper'

describe "TwitRSVP::Event" do
  before(:each) do
    @event = TwitRSVP::Event.gen
  end

  it "should create an event successfully" do
    @event.should be_valid
    @event.permalink.should_not be_nil
  end
end
