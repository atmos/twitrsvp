require File.dirname(__FILE__)+'/../spec_helper'

describe "modifying an event" do
  before(:each) do
    login_quentin
  end
  it "displays the event when the current_user is an attendee of the event" do
    user = TwitRSVP::User.first(:twitter_id => 1484261)
    event = TwitRSVP::Event.gen(:user_id => user.id)

    get "/events/#{event.id}/edit"

    last_response.should have_selector("form[action='/events/#{event.id}']")
    last_response.should have_selector("form[action='/events/#{event.id}'] label[for='name']")
    last_response.should have_selector("form[action='/events/#{event.id}'] input[type='hidden'][name='_method'][value='PUT']")
    last_response.should have_selector("form[action='/events/#{event.id}'] input[type='text'][name='name'][value='#{event.name}']")
    last_response.should have_selector("form[action='/events/#{event.id}'] label[for='place']")
    last_response.should have_selector("form[action='/events/#{event.id}'] input[type='text'][name='place'][value='#{event.place}']")
    last_response.should have_selector("form[action='/events/#{event.id}'] label[for='address']")
    last_response.should have_selector("form[action='/events/#{event.id}'] input[type='text'][name='address']")
    last_response.should have_selector("form[action='/events/#{event.id}'] label[for='description']")
    last_response.should have_selector("form[action='/events/#{event.id}'] textarea[name='description']:contains('#{event.description}')")
    last_response.should have_selector("form[action='/events/#{event.id}'] label[for='starts_at']")
    last_response.should have_selector("form[action='/events/#{event.id}'] input[type='text'][name='starts_at']")
    last_response.should have_selector("form[action='/events/#{event.id}'] p:contains('#{event.attendees.map { |attendee| attendee.user.screen_name }.join(',')}')")
    last_response.should have_selector("form[action='/events/#{event.id}'] textarea[name='usernames']")
    last_response.should have_selector("form[action='/events/#{event.id}'] input[type='submit'][value='Create!']")
    last_response.should have_selector("form[action='/events/#{event.id}'] a[href='/']:contains('Cancel')")
  end
end
