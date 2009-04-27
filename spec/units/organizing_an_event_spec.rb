require File.dirname(__FILE__)+'/../spec_helper'

describe "organizing an event" do
  before(:each) do
    FakeWeb.register_uri(:any, %r!^http://maps.google.com!,
                         [{:string => TwitRSVP::Fixtures.successful_google_response,   :status => ['200', 'OK']}])
    login_quentin
  end
  it "can organize events" do
    get '/organize'

    last_response.should have_selector("form[action='/organize']")
    last_response.should have_selector("form[action='/organize'] label[for='name']")
    last_response.should have_selector("form[action='/organize'] input[type='text'][name='name']")
    last_response.should have_selector("form[action='/organize'] label[for='place']")
    last_response.should have_selector("form[action='/organize'] input[type='text'][name='place']")
    last_response.should have_selector("form[action='/organize'] label[for='address']")
    last_response.should have_selector("form[action='/organize'] input[type='text'][name='address']")
    last_response.should have_selector("form[action='/organize'] label[for='description']")
    last_response.should have_selector("form[action='/organize'] textarea[name='description']")
    last_response.should have_selector("form[action='/organize'] label[for='starts_at']")
    last_response.should have_selector("form[action='/organize'] input[type='text'][name='starts_at']")
    last_response.should have_selector("form[action='/organize'] textarea[name='usernames']")
    last_response.should have_selector("form[action='/organize'] input[type='submit'][value='Create!']")
    last_response.should have_selector("form[action='/organize'] a[href='/']:contains('Cancel')")

    post '/organize', :name => /\w{4,20}/.gen, :place => /\w{4,20}/.gen,
      :starts_at => 'tonight at 8', :address => '1535 Pearl St, Boulder, CO',
      :usernames => 'atmos, ubermajestix', :description => /[:paragraph]/.gen[0..139]
    last_response.headers['Location'].should match(%r!/events/\d!)
  end
  it "should repopulate the form properly on failed signup" do
    post '/organize', :name => /\w{4,20}/.gen, :place => /\w{4,20}/.gen,
      :address => '1535 Pearl St, Boulder, CO', :usernames => 'atmos, ubermajestix', :description => /[:paragraph]/.gen[0..139]

    last_response.should have_selector("form[action='/organize']")
    last_response.should have_selector("form[action='/organize'] label[for='name']")
    last_response.should have_selector("form[action='/organize'] input[type='text'][name='name']")
    last_response.should have_selector("form[action='/organize'] label[for='place']")
    last_response.should have_selector("form[action='/organize'] input[type='text'][name='place']")
    last_response.should have_selector("form[action='/organize'] label[for='address']")
    last_response.should have_selector("form[action='/organize'] input[type='text'][name='address']")
    last_response.should have_selector("form[action='/organize'] label[for='description']")
    last_response.should have_selector("form[action='/organize'] textarea[name='description']")
    last_response.should have_selector("form[action='/organize'] label[for='starts_at']")
    last_response.should have_selector("form[action='/organize'] input[type='text'][name='starts_at']")
    last_response.should have_selector("form[action='/organize'] textarea[name='usernames']:contains('atmos, ubermajestix')")
    last_response.should have_selector("form[action='/organize'] input[type='submit'][value='Create!']")
    last_response.should have_selector("form[action='/organize'] a[href='/']:contains('Cancel')")
  end
end
