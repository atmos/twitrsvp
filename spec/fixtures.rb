TwitRSVP::User.fix {{
  :twitter_id => /\d{8,14}/.gen, 
  :name => "#{/\w{2,8}/.gen.capitalize} #{/\w{3,12}/.gen.capitalize}", 
  :token => /\w{8,16}/.gen, 
  :secret => /\w{8,16}/.gen
}}

TwitRSVP::Event.fix {{
  :user_id  => TwitRSVP::User.gen.id,
  :name     => /\w{8,20}/.gen,
  :place    => /\w{8,20}/.gen,
  :start_at => Time.now + 7200,
  :description => [:paragraph][0..139],
  :attendees => 7.of { TwitRSVP::Attendee.make }
}}

TwitRSVP::Attendee.fix {{
  :user_id  => TwitRSVP::User.gen.id
}}

TwitRSVP::Attendee.fix(:user) {{
  :event_id => TwitRSVP::Event.gen.id
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
end
