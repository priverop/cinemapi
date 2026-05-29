# frozen_string_literal: true

require "date"
require "uri"
require_relative "../base_orchestrator"

module Scraper
  module Mooby
    # Mooby Cinemas (Grup Balañà) serves the whole cartelera, every shop and
    # date, in one HTML page (window.shops JSON). We fetch it once, parse the
    # theater's shop, then fetch each movie's detail page once for the metadata
    # (duration, directors, genres) the feed omits, and finally group showtimes
    # by date to reuse the per-day error isolation of BaseOrchestrator.
    class Orchestrator < Scraper::BaseOrchestrator
      class << self
        private

        def calendar_days(theater)
          html   = Scraper.logger.tagged("Client") { Scraper::Client.read(URI(theater.website)) }
          movies = Scraper.logger.tagged("MovieParser") do
            Scraper::Mooby::MovieParser.new(html, theater.scraper_external_id).parse
          end
          enriched = enrich_with_details(movies, theater.website)
          group_by_date(enriched)
        end

        def process_day(theater, day)
          normalized = Scraper.logger.tagged("Normalizer") { Scraper::Mooby::Normalizer.new.normalize(day[:movies]) }
          Scraper.logger.tagged("Importer") { Scraper::Importer.new(theater:).import(normalized) }
        end

        def day_label(day) = day[:date]

        # Fetches each distinct movie's detail page once and merges its metadata
        # into every version/showtime entry. A failed fetch is logged and skipped
        # so one bad page never aborts the whole theater.
        def enrich_with_details(movies, website)
          base  = base_url(website)
          cache = {}
          movies.map do |movie|
            detail = cache[movie[:slug]] ||= fetch_detail(base, movie[:slug])
            movie.merge(detail) { |_key, existing, fetched| existing || fetched }
          end
        end

        def fetch_detail(base, slug)
          url  = URI.join(base, slug)
          html = Scraper.logger.tagged("Client") { Scraper::Client.read(url) }
          Scraper.logger.tagged("DetailParser") { Scraper::Mooby::DetailParser.new(html).parse }
        rescue => e
          Scraper.logger.error("Detail fetch failed for #{slug}: #{e.class}: #{e.message}.")
          {}
        end

        def base_url(website)
          uri = URI(website)
          "#{uri.scheme}://#{uri.host}"
        end

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
