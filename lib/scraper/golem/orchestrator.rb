# frozen_string_literal: true

require "uri"
require_relative "../base_orchestrator"

module Scraper
  module Golem
    class Orchestrator < Scraper::BaseOrchestrator
      class << self
        private

        def calendar_days(theater)
          base_url  = URI(theater.website)
          main_html = Scraper.logger.tagged("Client") { Scraper::Client.read(base_url) }
          days      = Scraper.logger.tagged("CalendarParser") { Scraper::Golem::CalendarParser.new(main_html).days }
          days.map { |day| day.merge(base_url: base_url) }
        end

        def process_day(theater, day)
          url        = day[:base_url].merge(day[:url])
          html       = Scraper.logger.tagged("Client") { Scraper::Client.read(url) }
          parsed     = Scraper.logger.tagged("MovieParser") { Scraper::Golem::MovieParser.new(html).parse }
          normalized = Scraper.logger.tagged("Normalizer") do
            Scraper::Golem::Normalizer.new(date: day[:date], base_url: day[:base_url]).normalize(parsed)
          end
          Scraper.logger.tagged("Importer") { Scraper::Importer.new(theater: theater).import(normalized) }
        end

        def day_label(day) = day[:date]
      end
    end
  end
end
