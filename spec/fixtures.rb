TwitRSVP::User.fix {{
  :twitter_id => /\d{8,14}/.gen,
  :screen_name => %w(atmos jlarrimore ubermajestix aniero stolt45).pick,
  :name => "#{/\w{2,8}/.gen.capitalize} #{/\w{3,12}/.gen.capitalize}",
  :token => /\w{8,16}/.gen,
  :secret => /\w{8,16}/.gen,
  :utc_offset => -25200,
  :time_zone => 'Mountain Time (US & Canada)'
}}

TwitRSVP::Event.fix {{
  :user_id  => TwitRSVP::User.gen.id,
  :name     => /\w{8,20}/.gen,
  :place    => /\w{8,20}/.gen,
  :start_at => Time.now.utc + 7200,
  :description => [:paragraph][0..139],
  :dm_key   => /\w{4}/.gen,
  :attendees => 7.of { TwitRSVP::Attendee.make }
}}

TwitRSVP::Attendee.fix {{
  :user_id  => TwitRSVP::User.gen.id,
}}

TwitRSVP::Attendee.fix(:user) {{
  :event_id => TwitRSVP::Event.gen.id,
}}

TwitRSVP::Attendee.fix(:standalone) {{
  :user_id  => TwitRSVP::User.gen.id,
  :event_id => TwitRSVP::Event.gen.id,
}}

module TwitRSVP::Fixtures
  def self.successful_google_response
    <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://earth.google.com/kml/2.0">
  <Response>
  <name>1535 pearl st boulder co</name>
  <Status>
    <code>200</code>
    <request>geocode</request>
  </Status>
  <Placemark id="p1">
    <address>1535 Pearl St, Boulder, CO 80302, USA</address>
    <AddressDetails xmlns="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0" Accuracy="8"><Country><CountryNameCode>US</CountryNameCode><CountryName>USA</CountryName><AdministrativeArea><AdministrativeAreaName>CO</AdministrativeAreaName><Locality><LocalityName>Boulder</LocalityName><Thoroughfare><ThoroughfareName>1535 Pearl St</ThoroughfareName></Thoroughfare><PostalCode><PostalCodeNumber>80302</PostalCodeNumber></PostalCode></Locality></AdministrativeArea></Country></AddressDetails>
    <ExtendedData>
      <LatLonBox north="40.0220413" south="40.0157461" east="-105.2720164" west="-105.2783116"/>
    </ExtendedData>
    <Point><coordinates>-105.2751640,40.0188937,0</coordinates></Point>
  </Placemark>
</Response>
</kml>
    EOF
  end
  def self.multi_google_response
    <<-EOF
<kml xmlns="http://earth.google.com/kml/2.0">
  <Response>
  <name>Lehigh St</name>
  <Status>
    <code>200</code>
    <request>geocode</request>
  </Status>
  <Placemark id="p1">
    <address>Lehigh St, PA 17925, USA</address>
    <AddressDetails xmlns="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0" Accuracy="6"><Country><CountryNameCode>US</CountryNameCode><CountryName>USA</CountryName><AdministrativeArea><AdministrativeAreaName>PA</AdministrativeAreaName><Thoroughfare><ThoroughfareName>Lehigh St</ThoroughfareName></Thoroughfare><PostalCode><PostalCodeNumber>17925</PostalCodeNumber></PostalCode></AdministrativeArea></Country></AddressDetails>
    <ExtendedData>
      <LatLonBox north="40.7979196" south="40.7916244" east="-75.9774134" west="-75.9837086"/>
    </ExtendedData>
    <Point><coordinates>-75.9805350,40.7947780,0</coordinates></Point>
  </Placemark>
  <Placemark id="p2">
    <address>Lehigh St, Allentown, PA, USA</address>
    <AddressDetails xmlns="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0" Accuracy="6"><Country><CountryNameCode>US</CountryNameCode><CountryName>USA</CountryName><AdministrativeArea><AdministrativeAreaName>PA</AdministrativeAreaName><Locality><LocalityName>Allentown</LocalityName><Thoroughfare><ThoroughfareName>Lehigh St</ThoroughfareName></Thoroughfare></Locality></AdministrativeArea></Country></AddressDetails>
    <ExtendedData>
      <LatLonBox north="40.5997540" south="40.5381090" east="-75.4651880" west="-75.4987940"/>
    </ExtendedData>
    <Point><coordinates>-75.4823990,40.5690340,0</coordinates></Point>
  </Placemark>
    EOF
  end

  def self.unsuccessful_google_response
    <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://earth.google.com/kml/2.0">
  <Response>
  <name>1535 pearl st boulder co</name>
  <Status>
    <code>401</code>
    <request>geocode</request>
  </Status>
  <Placemark id="p1">
    <address>1535 Pearl St, Boulder, CO 80302, USA</address>
    <AddressDetails xmlns="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0" Accuracy="8"><Country><CountryNameCode>US</CountryNameCode><CountryName>USA</CountryName><AdministrativeArea><AdministrativeAreaName>CO</AdministrativeAreaName><Locality><LocalityName>Boulder</LocalityName><Thoroughfare><ThoroughfareName>1535 Pearl St</ThoroughfareName></Thoroughfare><PostalCode><PostalCodeNumber>80302</PostalCodeNumber></PostalCode></Locality></AdministrativeArea></Country></AddressDetails>
    <ExtendedData>
      <LatLonBox north="40.0220413" south="40.0157461" east="-105.2720164" west="-105.2783116"/>
    </ExtendedData>
    <Point><coordinates>-105.2751640,40.0188937,0</coordinates></Point>
  </Placemark>
</Response>
</kml>
    EOF
  end

  def self.successful_direct_message_query(attendees)
    messages = attendees.map do |attendee|
      "{\"sender_id\":#{attendee.user.twitter_id},\"created_at\":\"#{::Chronic.parse("10 minutes ago").utc}\",\"text\":\"#{rand(10) % 2 == 0 ? 'yes' : 'no'} #{attendee.event.dm_key}\"}"
    end
    "[#{messages.join(',')}]"
  end
end
