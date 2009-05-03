require File.dirname(__FILE__)+'/../spec_helper'

describe "modifying an event" do
  before(:each) do
    login_quentin
  end
  it "displays the event when the current_user is an attendee of the event" do
    user = TwitRSVP::User.first(:twitter_id => 1484261)
    event = TwitRSVP::Event.gen(:user_id => user.id)

    get "/events/#{event.id}/edit"

    last_response.should have_selector("form[action='/events/#{event.id}'][method='POST']")
    last_response.should have_selector("form[action='/events/#{event.id}'] input[type='hidden'][name='_method'][value='put']")
    last_response.should have_selector("form[action='/events/#{event.id}'] label[for='name']")
    last_response.should have_selector("form[action='/events/#{event.id}'] input[type='text'][name='name'][value='#{event.name}']")
    last_response.should have_selector("form[action='/events/#{event.id}'] label[for='place']")
    last_response.should have_selector("form[action='/events/#{event.id}'] input[type='text'][name='place'][value='#{event.place}']")
    last_response.should have_selector("form[action='/events/#{event.id}'] label[for='address']")
    last_response.should have_selector("form[action='/events/#{event.id}'] textarea[name='address']")
    last_response.should have_selector("form[action='/events/#{event.id}'] label[for='start_date']")
    last_response.should have_selector("form[action='/events/#{event.id}'] input[type='text'][name='start_date'][value='#{TwitRSVP.date_format(quentin_time(event.start_at))}']")
    last_response.should have_selector("form[action='/events/#{event.id}'] label[for='start_time']")
    last_response.should have_selector("form[action='/events/#{event.id}'] input[type='text'][name='start_time'][value='#{TwitRSVP.time_format(quentin_time(event.start_at))}']")
    last_response.should have_selector("form[action='/events/#{event.id}'] label[for='description']")
    last_response.should have_selector("form[action='/events/#{event.id}'] textarea[name='description']:contains('#{event.description}')")
    last_response.should have_selector("form[action='/events/#{event.id}'] p:contains('#{event.attendees.map { |attendee| attendee.user.screen_name }.join(',')}')")
    last_response.should have_selector("form[action='/events/#{event.id}'] textarea[name='usernames']")
    last_response.should have_selector("form[action='/events/#{event.id}'] input[type='submit'][value='Create!']")
    last_response.should have_selector("form[action='/events/#{event.id}'] a.unsubmit.negative[href='/']:contains('Oh Nevermind')")
  end
end
