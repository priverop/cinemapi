# frozen_string_literal: true

require "logger"
require "uri"

module Scraper
  SOURCES = {
    "renoir" => "Scraper::Renoir::Orchestrator",
    "cinesa" => "Scraper::Cinesa::Orchestrator"
  }.freeze

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

  def self.run_all
    theaters = Theater.enabled.where.not(scraper_key: 0).where.not(website: nil)
    theaters.each do |theater|
      orchestrator = SOURCES.fetch(theater.scraper_key).constantize
      logger.tagged("Scraper", theater.scraper_key, theater.name) do
        orchestrator.run(theater)
      rescue => e
        logger.error("Scraping #{theater.name} failed: #{e.class}: #{e.message}.")
      end
    end
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
