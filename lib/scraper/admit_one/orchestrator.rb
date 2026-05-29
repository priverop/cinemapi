# frozen_string_literal: true

require "date"
require "uri"
require_relative "../base_orchestrator"

module Scraper
  module AdmitOne
    # Admit-one (Verdi Madrid, Cinemes Girona) returns all movies and all
    # dates in a single HTML page. We could skip the per-day pattern and
    # process everything together; we keep the BaseOrchestrator shape to stay
    # consistent with the other scrapers and benefit from per-day error
    # isolation and counters.
    class Orchestrator < Scraper::BaseOrchestrator
      class << self
        private

        def calendar_days(theater)
          url    = URI(theater.website)
          html   = Scraper.logger.tagged("Client") { Scraper::Client.read(url) }
          movies = Scraper.logger.tagged("MovieParser") { Scraper::AdmitOne::MovieParser.new(html).parse }
          group_by_date(movies)
        end

        def process_day(theater, day)
          normalized = Scraper.logger.tagged("Normalizer") { Scraper::AdmitOne::Normalizer.new.normalize(day[:movies]) }
          Scraper.logger.tagged("Importer") { Scraper::Importer.new(theater:).import(normalized) }
        end

        def day_label(day) = day[:date]

        def group_by_date(movies)
          buckets = Hash.new { |h, k| h[k] = [] }
          movies.each do |movie|
            movie[:showtimes].group_by { |st| date_key(st[:date]) }.each do |date, day_showtimes|
              buckets[date] << movie.merge(showtimes: day_showtimes)
            end
          end
          buckets.sort.map { |date, day_movies| { date: date, movies: day_movies } }
        end

        def date_key(raw_date)
          Date.strptime(raw_date.to_s[0, 8], "%Y%m%d")
        end
      end
    end
  end
end
