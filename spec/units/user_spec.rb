require File.dirname(__FILE__) + '/../spec_helper'

describe "twitrsvp" do
  before(:all) do
    @tweep = ::TwitRSVP::User.new(:twitter_id => /\d{8,14}/.gen, :name => "#{/\w{2,8}/.gen} #{/\w{3,12}/.gen}", 
                                  :token => /\w{8,16}/.gen, :secret => /\w{8,16}/.gen)
  end
  it "should create successfully" do
    @tweep.save.should be_true
  end
end
