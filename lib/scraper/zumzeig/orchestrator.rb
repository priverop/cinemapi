# frozen_string_literal: true

require "uri"
require_relative "../base_orchestrator"

module Scraper
  module Zumzeig
    class Orchestrator < Scraper::BaseOrchestrator
      class << self
        private

        def calendar_days(theater)
          base_url = URI(theater.website)
          html     = Scraper.logger.tagged("Client") { Scraper::Client.read(base_url) }
          movies   = Scraper.logger.tagged("CalendarParser") { Scraper::Zumzeig::CalendarParser.new(html).movies }
          movies.map { |movie| movie.merge(base_url: base_url) }
        end

        def process_day(theater, movie)
          url        = movie[:base_url].merge(movie[:url])
          html       = Scraper.logger.tagged("Client") { Scraper::Client.read(url) }
          parsed     = Scraper.logger.tagged("MovieParser") { Scraper::Zumzeig::MovieParser.new(html).parse }
          combined   = parsed.merge(showtimes: movie[:showtimes])
          normalized = Scraper.logger.tagged("Normalizer") do
            Scraper::Zumzeig::Normalizer.new(base_url: movie[:base_url]).normalize([ combined ])
          end
          Scraper.logger.tagged("Importer") { Scraper::Importer.new(theater: theater).import(normalized) }
        end

        def day_label(movie) = movie[:url]
      end
    end
  end
end
