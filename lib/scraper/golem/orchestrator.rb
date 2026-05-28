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
          enriched   = enrich_with_details(parsed, day[:base_url])
          normalized = Scraper.logger.tagged("Normalizer") do
            Scraper::Golem::Normalizer.new(date: day[:date], base_url: day[:base_url]).normalize(enriched)
          end
          Scraper.logger.tagged("Importer") { Scraper::Importer.new(theater: theater).import(normalized) }
        end

        def day_label(day) = day[:date]

        # Day pages omit movie duration, so we fetch each movie's detail page
        # once per day and merge its duration into the movie hash before
        # normalization. A failed fetch is logged and skipped so one bad page
        # never aborts the whole day.
        def enrich_with_details(movies, base_url)
          cache = {}
          movies.map do |movie|
            detail_url = movie[:detail_url]
            detail = detail_url ? (cache[detail_url] ||= fetch_detail(base_url, detail_url)) : {}
            movie.except(:detail_url).merge(detail)
          end
        end

        def fetch_detail(base_url, detail_url)
          url  = base_url.merge(URI::DEFAULT_PARSER.escape(detail_url))
          html = Scraper.logger.tagged("Client") { Scraper::Client.read(url) }
          Scraper.logger.tagged("DetailParser") { Scraper::Golem::DetailParser.new(html).parse }
        rescue => e
          Scraper.logger.error("Detail fetch failed for #{detail_url}: #{e.class}: #{e.message}.")
          {}
        end
      end
    end
  end
end
