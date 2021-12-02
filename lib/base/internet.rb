# frozen_string_literal: true

puts __FILE__ if defined?(DEBUG)

require 'open-uri'
require 'timeout'
class Internet
  @@available = true

  def self.available?
    return @@available unless @@available.nil?

    begin
      index = open('http://www.google.com').read
      if index.include?('<Title>Google')
        @@available = true
      else
        puts "open('http://www.google.com') returned false"
      end
    rescue Exception => e
      puts "open('http://www.google.com') raised an exception: #{e}"
      @@available = false
    end
    @@available
  end
end
