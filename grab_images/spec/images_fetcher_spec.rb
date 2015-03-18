require 'spec_helper'
require 'vcr'
require 'webmock/rspec'
require './images_fetcher'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/cassettes'
  config.hook_into :webmock
end

describe ImagesFetcher do
  let(:invalid_urls) { ['somewrongaddress', 'htt://boogle.som'] }
  let(:valid_urls)   { ['google.com', 'http://google.com'] }
  let(:valid_url)    { 'google.ru' }
  let(:full_url)     { 'http://google.ru' }

  subject(:google_fetcher) do
    VCR.use_cassette(:google) { ImagesFetcher.build valid_url }
  end

  describe '#new' do
    it 'raises an exception when url is invalid' do
      invalid_urls.each do |url|
        expect { ImagesFetcher.new URI(url) }.to raise_error
      end
    end
  end

  describe '::build' do
    it 'returns nil when url is invalid' do
      invalid_urls.each { |url| expect(ImagesFetcher.build url).to be_nil }
    end

    it 'returns a Fetcher object when url is valid' do
      # stub_request('https://google.com', 'http://google.com')
      expect(VCR.use_cassette(:google) { ImagesFetcher.build valid_url })
        .to be_instance_of(ImagesFetcher)
      # valid_urls.each do |url|
      #   expect(Fetcher.build url).to be_instance_of(Fetcher)
      # end
    end
  end

  it { should respond_to :uri }
  it { should respond_to :page }
  it { should respond_to :images }

  it { should respond_to :background_images }
  it { should respond_to :all_images }

  it 'makes a full path from a given url' do
    expect(google_fetcher.uri).to eq URI full_url
  end

  # its(:page) { should_not be_nil }
  # its(:images) { should_not be_nil }
  its(:images) { should be_kind_of Enumerable }
  its(:uri)    { should be_kind_of URI }
  its(:page)   { should be_kind_of Nokogiri::HTML::Document }

  it 'returns a lits of img tags on the page' do
    expect(google_fetcher.images.size).to eq 2
  end

  it 'returns a list of URIs of all images on the page' do
    expect(google_fetcher.all_images.size).to eq 3
  end

  it { should respond_to :download_images }
  it { should respond_to :download_images_mt }

  describe '#download_images' do
    it 'should create a folder if it doesnt exist' do
      allow(File).to receive(:directory?).with('tmp').and_return false
      
      expect(Dir).to receive(:mkdir).with('tmp')
      google_fetcher.download_images
    end

    it 'should download images' do
      expect(google_fetcher).to receive(:download).exactly(3).times
      google_fetcher.download_images
    end
  end
end
