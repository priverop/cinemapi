# frozen_string_literal: true

require "uri"

module Scraper
  module Renoir
    class Orchestrator
      class << self
        def run(theater)
          days_ok = 0
          days_failed = 0
          base_url = URI(theater.website)

          Scraper.logger.info("Starting scrape for #{base_url}.")

            main_html = Scraper::Client.read(base_url)
            calendar_urls = Scraper.logger.tagged("CalendarParser") { Scraper::Renoir::CalendarParser.new(main_html).urls }

            calendar_urls.each do |url|
              date = url.split("fecha=").last
              Scraper.logger.tagged(date) do
                begin
                  new_url = base_url.merge(url)
                  html = Scraper::Client.read(new_url)
                  parsed = Scraper.logger.tagged("MovieParser") { Scraper::Renoir::MovieParser.new(html).parse }
                  normalized = Scraper.logger.tagged("Normalizer") { Scraper::Renoir::Normalizer.new(date).normalize(parsed) }
                  Scraper.logger.tagged("Importer") { Scraper::Importer.new(theater:).import(normalized) }
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