require 'twitter'
require 'oauth'

class Object
  def blank?
    self.nil? || self.empty?
  end
end

CONSUMER_KEY = ENV['CONSUMER_KEY']
CONSUMER_SECRET = ENV['CONSUMER_SECRET']

if ENV['ACCESS_TOKEN'].blank? || ENV['ACCESS_TOKEN_SECRET']
  consumer = OAuth::Consumer.new(
    CONSUMER_KEY,
    CONSUMER_SECRET,
    site: 'https://api.twitter.com'
  )
  request_token = consumer.get_request_token
  system('open', request_token.authorize_url) || puts("Access here: #{request_token.authorize_url}")
  print 'Input PIN:'
  pin = gets.chomp
  access_token = request_token.get_access_token(
    oauth_token: request_token.token,
    oauth_verifier: pin
  )
  token = access_token.token
  secret = access_token.secret

  `echo 'export ACCESS_TOKEN=#{token}' >> .twitter_config`
  `echo 'export ACCESS_TOKEN_SECRET=#{secret}' >> .twitter_config`
end

client = Twitter::REST::Client.new do |config|
  config.consumer_key = CONSUMER_KEY
  config.consumer_secret = CONSUMER_SECRET
  config.access_token = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end

class Twitter::Tweet
  def to_text
    screen_name = self.user.screen_name
    time = self.created_at
    text = self.text
    <<-TEXT
    #{screen_name} (#{time})
    #{text}
    TEXT
  end
end

puts 'Twitter Client起動'
while true
  print 'cmd >> '

  cmd_type, message = gets.split(' ')

  case cmd_type.to_sym
  when :tw
    client.update(message)
    puts "Tweet with \"#{message}\""
  when :read
    timeline = client.home_timeline
    timeline.each do |tweet|
      puts tweet.to_text
    end
  when :exit
    puts 'End'
    exit
  end
end
