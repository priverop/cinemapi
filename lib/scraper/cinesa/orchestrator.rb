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

          # token = Scraper::Cinesa::AuthClient.fetch_headers(base_url)
          token = { "Authorization" => "Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjRBQUQ3MUYwRDI3OURBM0Y2NkMzNjJBM0JGMDRBMDFDNDBBNzU4RjciLCJ0eXAiOiJKV1QifQ.eyJzdWIiOiJlcnJ0ZTJnYXQxYzBoejJybmduMXd3ODB3OHFieTFkbTkiLCJnaXZlbl9uYW1lIjoiQ2luZXNhIiwiZmFtaWx5X25hbWUiOiJXZWIgSG9zdCIsInZpc3RhX29yZ2FuaXNhdGlvbl9jb2RlIjoibnY0cHNubWowMHBtOWYxNnN2YnFldmd4bm0wIiwicm9sZSI6IkNYTV9BY2Nlc3NSdWxlc0FwaSIsInRva2VuX3VzYWdlIjoiYWNjZXNzX3Rva2VuIiwianRpIjoiM2E5YzQyODUtMTAxMS00OTMxLTgyMzgtODc0ZmQ5OGNmNGQwIiwiYXVkIjoiYWxsIiwiYXpwIjoiQ2luZXNhIC0gRGlnaXRhbCBXZWIgRGV2IC0gUFJPRCIsIm5iZiI6MTc3NzU1NDAxNCwiZXhwIjoxNzc3NTk3MjE0LCJpYXQiOjE3Nzc1NTQwMTQsImlzcyI6Imh0dHBzOi8vYXV0aC5tb3ZpZXhjaGFuZ2UuY29tLyJ9.q2KP-cfWXkr4n8pHCB-grKE2cpDiiuiyKRQGnNfmAzmx8RCQmxgkGcHqOcAkl3RsUYmMsHQw7oEBv2cYUK9zwRPn-GtwqNx1YAsDePDK33VV7ccJg9g7uDvIY2MrwHdvZLerhW1MpL9c238_KyG-tERQDWz4w-YdbNT4xP7Fqdz0J47VKuQbrLsbatSuVb17dn8n-EyyBuRC-FHujLnwfsqBjtdCE-Fh7VYwzMHOOdG5QV4WhlXP6mHk7Kk0hbehWthrx_MwOBHk0vYs-t2dFAjwrugx0d5aSO9YkpK3i1H8N-0USkcSwA9tAG78ojf2tIv-WfOQT8bOZoMkLGSs7PS_SFKFbXysvL8UFppl_VyJGcJW2-EGdjVIeeqNZHbEkD6kOI6o8CkNmtE_HWuh19vIcaCAFnfhXRvbOZaW-en8b9vAdK7lc9YdL0z8zhPhcZQEdHFWATsI2O81ICXtXNvi0udth2rXTrJUrg55b3ZMl-NfD2OQCrsvI3XUcm3fr0UGoS2OYufE75A8ICdzIJAJbZfvlNLk94MVQLCHXCu7DzEp8i_VFxkGGbcytzp0IrUacUih09j1zEtBqy73AR-TDftv9AwA8JUVZovClEJEI4itUtZila1tKC5hB1y_jXPuEnMw-8SXVTZriRVH_h7enpakQLeuAo00_beARDc" }
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
