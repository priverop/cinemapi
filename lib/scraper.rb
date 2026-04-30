# frozen_string_literal: true

require "logger"

module Scraper
  def self.logger
    @logger ||= defined?(Rails) ? Rails.logger : Logger.new($stdout)
  end

  def self.logger=(logger)
    @logger = logger
  end

  class InvalidUrlError < StandardError; end
  class MoviesNotFoundError < StandardError; end
  class CalendarNotFoundError < StandardError; end
  class UnknownLanguageError < StandardError; end
  class AuthRequiredError < StandardError; end
end
