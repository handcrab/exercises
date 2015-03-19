#!/usr/bin/env ruby
require './images_fetcher_sel'

if ARGV.size < 2
  puts 'Wrong number of arguments'
  puts './grab_sel.rb <url> <destination>'
  puts "Example: ./grab_sel.rb www.google.com /tmp"
  exit
end

fetcher = ImagesFetcher.build ARGV[0]

unless fetcher
  puts 'Sorry, but URL is invalid, or page is unreacheable'
  exit
end

fetcher.run do |f|
  imgs = f.all_images
  # imgs = f.background_images
  puts "Found: #{imgs.size} images"
  f.download_images_mt ARGV[1], imgs
end
