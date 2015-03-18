require 'open-uri'
require 'nokogiri'
require 'open_uri_redirections' # fix: http -> https redirections

class ImagesFetcher
  attr_reader :uri, :page, :images

  def self.build url
    uri = URI url
    uri = URI "http://#{url}" unless uri.scheme
    new uri
  rescue
    nil
  end

  def initialize uri
    @uri  = uri
    @page = fetch_page
  end

  # => [] of Nokogiri::XML::Element
  def images
    return [] unless @page
    @images ||= @page.css 'img'
  end

  # => [] of Strings
  def background_images
    # works only with embedded style attr
    @page.css('[style]').map { |e| e.attr(:style)[/url\((.+)\)/, 1] }.compact
      .select { |link| image? link }
  end

  # => [] of URIs
  def all_images
    img_urls = images.map { |img| image_uri(img) }
    bg_urls  = background_images.map { |img| image_uri(img) }
    img_urls + bg_urls
  end

  def download_images dest = 'tmp'
    Dir.mkdir(dest) unless File.directory?(dest)
    all_images.each do |img_url|
      # download image_uri(img.attr(:src)), dest
      download img_url, dest
    end
  end

  # download_images with threads
  def download_images_mt dest = 'tmp'
    Dir.mkdir(dest) unless File.directory?(dest)

    threads = []
    all_images.each do |img|
      threads << Thread.new(img) { |img_url| download img_url, dest }
    end
    threads.each(&:join)
  end

  private

  def fetch_page
    Nokogiri::HTML open(@uri.to_s, allow_redirections: :safe)
  end

  def image? url
    url =~ /(.*)\.(jpg|jpeg|png|gif)/i
  end

  # img = Nokogiri::XML::Element or Sting
  # => URI
  def image_uri img
    img = img.respond_to?(:attr) ? img.attr(:src) : img.to_s
    img = URI img
    return img if img.host && img.scheme

    # img with relative path?
    img.scheme = @uri.scheme
    img.host   = @uri.host unless img.host
    img.port   = @uri.port unless img.port

    img
  end

  # src, dest = String
  def download src, dest
    dest_path = File.join dest, File.basename(src.to_s)
    puts "Downloading: #{src} to #{dest_path}"

    File.write dest_path, open(src.to_s).read
  rescue
    puts "Sorry, something wrong with #{src}"
  end
end
