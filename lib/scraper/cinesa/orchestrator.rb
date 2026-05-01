# frozen_string_literal: true

require "uri"
require "debug"

module Scraper
  module Cinesa
    class Orchestrator
      class << self
        def run(theater)
          days_ok = 0
          days_failed = 0
          base_url = theater.website
          calendar_url = "https://vwc.cinesa.es/WSVistaWebClient/ocapi/v1/film-screening-dates"
          movies_url = "https://vwc.cinesa.es/WSVistaWebClient/ocapi/v1/showtimes/by-business-date"

          Scraper.logger.info("Starting scrape for #{base_url}.")

          token = Scraper::Cinesa::AuthClient.fetch_headers(base_url)
          client = Scraper::Cinesa::ApiClient.new(token, theater.scraper_external_id)
          calendar_data = Scraper.logger.tagged("ApiClient") { client.data(calendar_url) }
          calendar_dates = Scraper.logger.tagged("CalendarParser") { Scraper::Cinesa::CalendarParser.new(calendar_data).parse }

          calendar_dates[0...7].each do |date|
            Scraper.logger.tagged(date) do
              begin
                raw_data = Scraper.logger.tagged("ApiClient") { client.data("#{movies_url}/#{date}") }
                parsed_data = Scraper.logger.tagged("MovieParser") do
                  parser =  Scraper::Cinesa::MovieParser.new(raw_data)
                  parser.parse
                end
                normalized_data = Scraper.logger.tagged("Normalizer") { Scraper::Cinesa::Normalizer.normalize(parsed_data) }
                Scraper.logger.tagged("Importer") { Scraper::Importer.new(theater:).import(normalized_data) }
                days_ok += 1
              rescue => e
                days_failed += 1
                Scraper.logger.error("Day #{date} failed: #{e.class}: #{e.message}.")
              end
            end
          end

          Scraper.logger.info("Done. days_ok=#{days_ok} days_failed=#{days_failed}.")
        end
      end
    end
  end
end
