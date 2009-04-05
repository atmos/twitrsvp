require File.dirname(__FILE__)+'/../spec_helper'

describe "organizing an event" do
  it "can organize events" do
    login_quentin

    get '/organize'
    last_response.should have_selector("fieldset legend:contains('Organize an Event')")
    last_response.should have_selector("form[action='/organize']")
    last_response.should have_selector("form[action='/organize'] label[for='name']")
    last_response.should have_selector("form[action='/organize'] input[type='text'][name='name']")
    last_response.should have_selector("form[action='/organize'] label[for='place']")
    last_response.should have_selector("form[action='/organize'] input[type='text'][name='place']")
    last_response.should have_selector("form[action='/organize'] label[for='starts_at']")
    last_response.should have_selector("form[action='/organize'] input[type='text'][name='starts_at']")
    last_response.should have_selector("form[action='/organize'] label[for='ends_at']")
    last_response.should have_selector("form[action='/organize'] input[type='text'][name='ends_at']")
    last_response.should have_selector("form[action='/organize'] label[for='map_link']")
    last_response.should have_selector("form[action='/organize'] input[type='text'][name='map_link']")
    last_response.should have_selector("form[action='/organize'] input[type='text'][name='usernames']")
    last_response.should have_selector("form[action='/organize'] input[type='submit'][value='Create!']")
    last_response.should have_selector("form[action='/organize'] a[href='/']:contains('Cancel')")

    post '/organize', :name => /\w{4,20}/.gen, :place => /\w{4,20}/.gen,
      :starts_at => 'tonight at 8', :ends_at => 'tonight at 11', :map_link => 'http://craigslist.org',
      :usernames => 'atmos, ubermajestix'
    last_response.headers['Location'].should match(%r!/events/\d!)
  end
end
