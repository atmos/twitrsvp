require File.dirname(__FILE__) + '/../spec_helper'

describe "TwitRSVP::Event" do
  before(:each) do
    @user = TwitRSVP::User.gen
  end

  it "should create an event successfully" do
    event = TwitRSVP::Event.new(:name => 'Hennessey and Weed Night', :user_id => @user.id,
                                :map_link => 'http://maps.google.com/maps?client=safari&q=eiffel+tower&oe=UTF-8&ie=UTF8&hl=en&z=16&iwloc=A',
                                :start_time => 'Tonight at 8', :end_time => 'Tonight at 11')
    event.save.should be_true
    event.should be_valid
  end
end
