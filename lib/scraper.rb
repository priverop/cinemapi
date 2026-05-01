# frozen_string_literal: true

require "logger"

module Scraper
  def self.logger
    @logger ||= defined?(Rails) ? Rails.logger : Logger.new($stdout)
  end

  def self.logger=(logger)
    @logger = logger
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
