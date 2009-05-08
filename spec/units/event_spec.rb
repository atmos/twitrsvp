require File.dirname(__FILE__) + '/../spec_helper'

describe "TwitRSVP::Event" do
  before(:each) do
    @event = TwitRSVP::Event.gen
  end

  it "should create an event successfully" do
    @event.should be_valid
    @event.permalink.should_not be_nil
  end

  describe "address" do
    it "should handle creating a 'google map link' with a URL" do
      @event.address = 'http://atmos.org'
      @event.google_map_link.should eql('http://atmos.org')
    end
    it "should handle creating a 'google map link' with a street address" do
      @event.address = "2017 13th St Boulder, CO 80302"
      @event.google_map_link.should eql('http://maps.google.com/maps?q=2017+13th+St+Boulder,+CO+80302')
    end
  end
end
