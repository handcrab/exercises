#!/usr/bin/env ruby
require './images_fetcher'

if ARGV.size < 2
  puts 'Wrong number of arguments'
  puts './grab.rb <url> <destination>'
  puts "Example: ./grab.rb www.google.com /tmp"
  exit
end

fetcher = ImagesFetcher.build ARGV[0]

unless fetcher
  puts 'Sorry, but URL is invalid, or page is unreacheable'
  exit
end

puts "Found: #{fetcher.all_images.size} images"
# fetcher.download_images ARGV[1]
fetcher.download_images_mt ARGV[1]
