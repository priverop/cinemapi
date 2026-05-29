# frozen_string_literal: true

require "uri"
require_relative "../base_orchestrator"

module Scraper
  module Mk2
    class Orchestrator < Scraper::BaseOrchestrator
      class << self
        private

        def calendar_days(theater)
          base_url = URI(theater.website)
          html     = Scraper.logger.tagged("Client") { Scraper::Client.read(base_url) }
          days     = Scraper.logger.tagged("CalendarParser") { Scraper::Mk2::CalendarParser.new(html).days }
          days[0...7].map { |day| day.merge(html:) }
        end

        def process_day(theater, day)
          parsed     = Scraper.logger.tagged("MovieParser") { Scraper::Mk2::MovieParser.new(day[:html], day[:num]).parse }
          normalized = Scraper.logger.tagged("Normalizer")  { Scraper::Mk2::Normalizer.new(day[:date]).normalize(parsed) }
          Scraper.logger.tagged("Importer") { Scraper::Importer.new(theater:).import(normalized) }
        end

        def day_label(day) = day[:date].to_s
      end
    end
  end
end
