TwitRSVP::User.fix {{
  :twitter_id => /\d{8,14}/.gen, 
  :name => "#{/\w{2,8}/.gen} #{/\w{3,12}/.gen}", 
  :token => /\w{8,16}/.gen, 
  :secret => /\w{8,16}/.gen
}}
