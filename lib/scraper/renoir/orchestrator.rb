# frozen_string_literal: true

require "uri"
require_relative "../base_orchestrator"

module Scraper
  module Renoir
    class Orchestrator < Scraper::BaseOrchestrator
      class << self
        private

        def calendar_days(theater)
          base_url  = URI(theater.website)
          main_html = Scraper.logger.tagged("Client") { Scraper::Client.read(base_url) }
          days      = Scraper.logger.tagged("CalendarParser") { Scraper::Renoir::CalendarParser.new(main_html).days }
          days.map { |day| day.merge(base_url:) }
        end

        def process_day(theater, day)
          url        = day[:base_url].merge(day[:url])
          html       = Scraper.logger.tagged("Client") { Scraper::Client.read(url) }
          parsed     = Scraper.logger.tagged("MovieParser") { Scraper::Renoir::MovieParser.new(html).parse }
          normalized = Scraper.logger.tagged("Normalizer") { Scraper::Renoir::Normalizer.new(day[:date]).normalize(parsed) }
          Scraper.logger.tagged("Importer") { Scraper::Importer.new(theater:).import(normalized) }
        end

        def day_label(day) = day[:date]
      end
    end
  end
end
