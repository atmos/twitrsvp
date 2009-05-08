require File.dirname(__FILE__)+'/../spec_helper'

describe "organizing an event" do
  before(:each) do
    FakeWeb.register_uri(:any, %r!^http://maps.google.com!,
                         [{:string => TwitRSVP::Fixtures.successful_google_response,   :status => ['200', 'OK']}])
    login_quentin
  end
  it "can schedule events" do
    get '/schedule'

    last_response.should have_selector("h1:contains('Welcome Quentin Blake,')")
    last_response.should have_selector("form[action='/events']")
    last_response.should_not have_selector("form[action='/events'][name='_method'][value='put']")
    last_response.should have_selector("form[action='/events'] label[for='name']")
    last_response.should have_selector("form[action='/events'] input[type='text'][name='name']")
    last_response.should have_selector("form[action='/events'] label[for='place']")
    last_response.should have_selector("form[action='/events'] input[type='text'][name='place']")
    last_response.should have_selector("form[action='/events'] label[for='address']")
    last_response.should have_selector("form[action='/events'] textarea[name='address']")
    last_response.should have_selector("form[action='/events'] label[for='description']")
    last_response.should have_selector("form[action='/events'] textarea[name='description']")
    last_response.should have_selector("form[action='/events'] label[for='start_date']")
    last_response.should have_selector("form[action='/events'] input[type='text'][name='start_date']")
    last_response.should have_selector("form[action='/events'] label[for='start_time']")
    last_response.should have_selector("form[action='/events'] input[type='text'][name='start_time']")
    last_response.should have_selector("form[action='/events'] textarea[name='usernames']")
    last_response.should have_selector("form[action='/events'] input[type='submit'][value='Create!']")
    last_response.should have_selector("form[action='/events'] a.unsubmit.negative[href='/manage']:contains('Oh Nevermind')")

    post '/events', :name => /\w{4,20}/.gen, :place => /\w{4,20}/.gen, :address => '1535 Pearl St, Boulder, CO',
      :start_date => Time.now.utc.strftime('%Y/%m/%d'), :start_time => Time.now.utc.strftime('%l:%M'),
      :usernames => 'atmos, ubermajestix', :description => /[:paragraph]/.gen[0..139]
    last_response.headers['Location'].should match(%r!/events/[^/]{36}!)
  end
  it "should repopulate the form properly on failed signup" do
    post '/events', :address => '1535 Pearl St, Boulder, CO', 
      :start_date => Time.now.utc.strftime('%Y/%m/%d'), :start_time => Time.now.utc.strftime('%l:%M'),
      :usernames => 'atmos, ubermajestix', :description => /[:paragraph]/.gen[0..139]

    last_response.should have_selector("h1:contains('Welcome Quentin Blake,')")
    last_response.should have_selector(".message.decline h2.orange:contains('Place must not be blank')")
    last_response.should have_selector(".message.decline h2.orange:contains('Name must not be blank')")
    last_response.should have_selector("form[action='/events']")
    last_response.should_not have_selector("form[action='/events'][name='_method'][value='put']")
    last_response.should have_selector("form[action='/events'] label[for='name']")
    last_response.should have_selector("form[action='/events'] input[type='text'][name='name']")
    last_response.should have_selector("form[action='/events'] label[for='place']")
    last_response.should have_selector("form[action='/events'] input[type='text'][name='place']")
    last_response.should have_selector("form[action='/events'] label[for='address']")
    last_response.should have_selector("form[action='/events'] textarea[name='address']")
    last_response.should have_selector("form[action='/events'] label[for='description']")
    last_response.should have_selector("form[action='/events'] textarea[name='description']")
    last_response.should have_selector("form[action='/events'] label[for='start_date']")
    last_response.should have_selector("form[action='/events'] input[type='text'][name='start_date']")
    last_response.should have_selector("form[action='/events'] label[for='start_time']")
    last_response.should have_selector("form[action='/events'] input[type='text'][name='start_time']")
    last_response.should have_selector("form[action='/events'] textarea[name='usernames']:contains('atmos, ubermajestix')")
    last_response.should have_selector("form[action='/events'] input[type='submit'][value='Create!']")
    last_response.should have_selector("form[action='/events'] a.unsubmit.negative[href='/manage']:contains('Oh Nevermind')")
  end
end
