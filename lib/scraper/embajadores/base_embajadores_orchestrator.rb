# frozen_string_literal: true

require "uri"
require_relative "../base_orchestrator"

module Scraper
  module Embajadores
    class BaseEmbajadoresOrchestrator < Scraper::BaseOrchestrator
      class << self
        private

        def calendar_days(theater)
          base_url = URI(theater.website)
          html     = Scraper.logger.tagged("Client") { Scraper::Client.read(base_url) }
          Scraper.logger.tagged("CalendarParser") { Scraper::Embajadores::CalendarParser.new(html).days }
        end

        def process_day(theater, day)
          html       = Scraper.logger.tagged("Client") { Scraper::Client.read(URI(day[:url])) }
          parsed     = Scraper.logger.tagged("MovieParser") { Scraper::Embajadores::MovieParser.new(html).parse }
          normalized = Scraper.logger.tagged("Normalizer") { Scraper::Embajadores::Normalizer.new(day[:date], venue_slug).normalize(parsed) }
          Scraper.logger.tagged("Importer") { Scraper::Importer.new(theater:).import(normalized) }
        end

        def day_label(day) = day[:date].to_s

        def venue_slug
          raise NotImplementedError, "#{name} must implement .venue_slug."
        end
      end
    end
  end
end
