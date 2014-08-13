require 'twitter'

client = Twitter::REST::Client.new do |config|
  config.consumer_key = ENV['CONSUMER_KEY']
  config.consumer_secret = ENV['CONSUMER_SECRET']
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
