# frozen_string_literal: true

require "uri"
require_relative "../base_orchestrator"

module Scraper
  module Malda
    # Hybrid scraper: the cartelera-dia-dia free-text block is the complete
    # weekly schedule; each film's detail page (resolved via PostFinder) adds the
    # metadata. Films missing from WordPress are still imported, schedule-only.
    class Orchestrator < Scraper::BaseOrchestrator
      class << self
        private

        def calendar_days(theater)
          base_url = URI(theater.website)
          html     = Scraper.logger.tagged("Client") { Scraper::Client.read(base_url) }
          movies   = Scraper.logger.tagged("CalendarParser") { Scraper::Malda::CalendarParser.new(html).movies }
          movies.map { |movie| movie.merge(base_url: base_url) }
        end

        def process_day(theater, movie)
          base_url   = movie[:base_url]
          combined   = enrich(movie, base_url)
          normalized = Scraper.logger.tagged("Normalizer") do
            Scraper::Malda::Normalizer.new(base_url: base_url).normalize([ combined ])
          end
          Scraper.logger.tagged("Importer") { Scraper::Importer.new(theater: theater).import(normalized) }
        end

        def enrich(movie, base_url)
          url = Scraper.logger.tagged("PostFinder") { Scraper::Malda::PostFinder.new(base_url: base_url).url(movie[:title]) }
          return movie if url.nil?

          html   = Scraper.logger.tagged("Client") { Scraper::Client.read(url) }
          parsed = Scraper.logger.tagged("MovieParser") { Scraper::Malda::MovieParser.new(html).parse }
          parsed.merge(showtimes: movie[:showtimes], language: movie[:language])
        end

        def day_label(movie) = movie[:title]
      end
    end
  end
end
