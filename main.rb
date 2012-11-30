require 'bundler'
require 'librato/metrics'
require 'nokogiri'
require 'open-uri'
require 'yaml'

config = YAML.load_file("./config.yml")
METRIC_NAME   = config["metric_name"]
LIBRATO_EMAIL = config["librato_email"]
LIBRATO_KEY   = config["librato_key"]
PLAY_URL      = config["play_url"]

class AverageRating
  def initialize(url)
    @url = url
  end

  def get_average!
    Nokogiri::HTML(open(@url)).css(".average-rating-value").first.text.gsub(",",".").to_f
  end
end

class Reporter
  def initialize
    Librato::Metrics.authenticate LIBRATO_EMAIL, LIBRATO_KEY
    @scrapper = AverageRating.new(PLAY_URL)
  end

  def report!
    Librato::Metrics.submit METRIC_NAME.to_sym => @scrapper.get_average!
  end
end

reporter = Reporter.new
loop do
  reporter.report!
  sleep(60)
end
