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
    it "should set a model error object if it returns too many results" do
      FakeWeb.register_uri(:any, %r!^http://maps.google.com!,
        [{:string => TwitRSVP::Fixtures.multi_google_response,   :status => ['200', 'OK']}])
      @event.address = "Lehigh St"
      @event.save
      @event.should be_valid
    end
    it "should set a model error object if it returns too many results" do
      FakeWeb.register_uri(:any, %r!^http://maps.google.com!,
        [{:string => TwitRSVP::Fixtures.multi_google_response,   :status => ['200', 'OK']}])
      @event.address = "Lehigh St"
      @event.update
      @event.should be_valid
    end
  end
end
