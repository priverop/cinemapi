# frozen_string_literal: true

require "logger"
require "uri"

module Scraper
  def self.logger
    @logger ||= defined?(Rails) ? Rails.logger : Logger.new($stdout)
  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.valid_http_url?(value)
    uri = value.is_a?(URI::Generic) ? value : URI.parse(value.to_s)
    uri.is_a?(URI::HTTP) && !uri.host.to_s.empty?
  rescue URI::InvalidURIError
    false
  end

  class ScraperError < StandardError; end
  class InvalidUrlError < ScraperError; end
  class MoviesNotFoundError < ScraperError; end
  class InvalidMovieError < ScraperError; end
  class CalendarNotFoundError < ScraperError; end
  class UnknownLanguageError < ScraperError; end
  class AuthRequiredError < ScraperError; end
  class HttpError < ScraperError; end
end
