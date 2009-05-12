require File.dirname(__FILE__)+'/../spec_helper'

describe "modifying an event" do
  before(:each) do
    login_quentin
  end
  it "displays the event when the current_user is an attendee of the event" do
    user = TwitRSVP::User.first(:twitter_id => 1484261)
    event = TwitRSVP::Event.gen(:user_id => user.id)

    get "/events/#{event.permalink}/edit"

    last_response.should have_selector("form[action='/events/#{event.permalink}'][method='POST']")
    last_response.should have_selector("form[action='/events/#{event.permalink}'] input[type='hidden'][name='_method'][value='put']")
    last_response.should have_selector("form[action='/events/#{event.permalink}'] label[for='name']")
    last_response.should have_selector("form[action='/events/#{event.permalink}'] input[type='text'][name='name'][value='#{event.name}']")
    last_response.should have_selector("form[action='/events/#{event.permalink}'] label[for='place']")
    last_response.should have_selector("form[action='/events/#{event.permalink}'] input[type='text'][name='place'][value='#{event.place}']")
    last_response.should have_selector("form[action='/events/#{event.permalink}'] label[for='address']")
    last_response.should have_selector("form[action='/events/#{event.permalink}'] textarea[name='address']")
    last_response.should have_selector("form[action='/events/#{event.permalink}'] label[for='start_date']")
    last_response.should have_selector("form[action='/events/#{event.permalink}'] input[type='text'][name='start_date'][value='#{TwitRSVP.date_format(quentin_time(event.start_at))}']")
    last_response.should have_selector("form[action='/events/#{event.permalink}'] label[for='start_time']")
    last_response.should have_selector("form[action='/events/#{event.permalink}'] input[type='text'][name='start_time'][value='#{TwitRSVP.time_format(quentin_time(event.start_at))}']")
    last_response.should have_selector("form[action='/events/#{event.permalink}'] label[for='description']")
    last_response.should have_selector("form[action='/events/#{event.permalink}'] textarea[name='description']:contains('#{event.description}')")
    last_response.should have_selector("form[action='/events/#{event.permalink}'] textarea[name='usernames']")
    last_response.should have_selector("form[action='/events/#{event.permalink}'] input[type='submit'][value='Done Editing!']")
    last_response.should have_selector("form[action='/events/#{event.permalink}'] a.unsubmit.negative[href='/events/#{event.permalink}']:contains('Oh Nevermind')")
  end
  it "should limit to 20 invitees" do
    user = TwitRSVP::User.first(:twitter_id => 1484261)
    event = TwitRSVP::Event.gen(:user_id => user.id)

    get "/events/#{event.permalink}/edit"

    put "/events/#{event.permalink}", :usernames => (0..20).map { /\w{8}/.gen.downcase }.join(','),
      :name => event.name, :place => event.place, :start_date => event.start_at.strftime('%Y/%m/%d'),
      :start_time => event.start_at.strftime('%Y/%m/%d'), :description => event.description

    last_response.should have_selector("form[action='/events/#{event.permalink}'][method='POST']")
    last_response.should have_selector("h1:contains('Editing: #{event.name}')")
    last_response.should have_selector(".message.decline h2.orange:contains('20 User Limit Exceeded')")
  end
end
