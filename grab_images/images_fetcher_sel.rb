require 'selenium-webdriver'
require 'open-uri'

class ImagesFetcher
  attr_reader :uri, :page, :images

  def self.build url
    uri = URI url
    uri = URI "http://#{url}" unless uri.scheme
    new uri
  rescue
    nil
  end

  def run # &block
    fetch_page
    yield self
    @page.quit
  end

  def initialize uri
    @uri  = uri
    # fetch_page
  end

  # => [] of Strings
  def images
    return [] unless @page
    # @images ||= images
    @images = @page.find_elements(css: 'img')
                   .map { |img| img.attribute(:src) }
                   .compact.uniq
  end

  # => [] of Strings
  def background_images
    return [] unless @page

    # super slow :/
    # elems = @page.find_elements(css: '*')
    #              .select { |e| e.css_value('background-image') != 'none' }
    #              .map do |e|
    #                e.css_value('background-image')[/url\(["'](.+)["']\)/, 1]
    #              end.compact.uniq

    # faster with JS
    script = <<-JS
      return (function() {
        var arrr = [];
        var list = document.getElementsByTagName('*');
        for (var i = 0; i < list.length; i++) {
          var tmp = window.getComputedStyle(list[i])['background-image'];
          if(tmp != 'none'){ arrr.push(tmp); }
        }
        return arrr;
      })()
    JS
    script.gsub! "\n", ''
    img_links = @page.execute_script(script) || []
    img_links.map { |link| link[/url\(["'](.+)["']\)/, 1] }
             .compact.uniq
             .select { |link| image? link } # skip binary image data
  end

  # => [] of URIs
  def all_images
    img_urls = images.map { |img| image_uri(img) }
    bg_urls  = background_images.map { |img| image_uri(img) }
    img_urls + bg_urls
  end

  def download_images dest = 'tmp', imgs = all_images
    Dir.mkdir(dest) unless File.directory?(dest)
    imgs.each { |img_url| download img_url, dest }
    nil
  end

  # download_images with threads
  def download_images_mt dest = 'tmp', imgs = all_images
    Dir.mkdir(dest) unless File.directory?(dest)

    threads = []
    imgs.each do |img|
      threads << Thread.new(img) { |img_url| download img_url, dest }
    end
    threads.each(&:join)
    nil
  end

  private

  def fetch_page
    @page = Selenium::WebDriver.for :firefox
    @page.navigate.to @uri
  end

  def image? url
    url =~ /(.*)\.(jpg|jpeg|png|gif|svg)/i
  end

  # img = Sting
  # => URI
  def image_uri img
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
    # TODO: normalize filenames
    dest_path = File.join dest, File.basename(src.to_s)
    puts "Downloading: #{src} to #{dest_path}"

    File.write dest_path, open(src.to_s).read
  rescue
    puts "Sorry, something wrong with #{src}"
  end
end