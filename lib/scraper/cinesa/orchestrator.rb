# frozen_string_literal: true

require_relative "../base_orchestrator"

module Scraper
  module Cinesa
    class Orchestrator < Scraper::BaseOrchestrator
      CALENDAR_URL = "https://vwc.cinesa.es/WSVistaWebClient/ocapi/v1/film-screening-dates"
      MOVIES_URL   = "https://vwc.cinesa.es/WSVistaWebClient/ocapi/v1/showtimes/by-business-date"

      class << self
        private

        def calendar_days(theater)
          token  = Scraper::Cinesa::AuthClient.fetch_headers(theater.website)
          client = Scraper::Cinesa::ApiClient.new(token, theater.scraper_external_id)
          data   = Scraper.logger.tagged("ApiClient") { client.data(CALENDAR_URL) }
          dates  = Scraper.logger.tagged("CalendarParser") { Scraper::Cinesa::CalendarParser.new(data).parse }
          dates[0...7].map { |date| { date:, client: } }
        end

        def process_day(theater, day)
          raw_data   = Scraper.logger.tagged("ApiClient") { day[:client].data("#{MOVIES_URL}/#{day[:date]}") }
          parsed     = Scraper.logger.tagged("MovieParser") { Scraper::Cinesa::MovieParser.new(raw_data).parse }
          normalized = Scraper.logger.tagged("Normalizer") { Scraper::Cinesa::Normalizer.new.normalize(parsed) }
          Scraper.logger.tagged("Importer") { Scraper::Importer.new(theater:).import(normalized) }
        end

        def day_label(day) = day[:date]
      end
    end
  end
end
