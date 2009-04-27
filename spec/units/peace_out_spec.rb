require File.dirname(__FILE__)+'/../spec_helper'

describe "peacing out" do
  it "clears your session" do
    login_quentin
    get '/peace'

    get '/'
    last_response.should have_selector("h2 > a[href='/signup']:contains('Get Started Now')")
  end
end

