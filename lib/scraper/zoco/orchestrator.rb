# frozen_string_literal: true

require "uri"
require_relative "../base_orchestrator"

module Scraper
  module Zoco
    class Orchestrator < Scraper::BaseOrchestrator
      class << self
        private

        def calendar_days(theater)
          base_url = URI(theater.website)
          html     = Scraper.logger.tagged("Client") { Scraper::Client.read(base_url) }
          Scraper.logger.tagged("ListParser") { Scraper::Zoco::ListParser.new(html).movies }
        end

        def process_day(theater, movie)
          url        = URI(movie[:url])
          html       = Scraper.logger.tagged("Client") { Scraper::Client.read(url) }
          parsed     = Scraper.logger.tagged("MovieParser") { Scraper::Zoco::MovieParser.new(html).parse }
          normalized = Scraper.logger.tagged("Normalizer") { Scraper::Zoco::Normalizer.new.normalize([ parsed ]) }
          Scraper.logger.tagged("Importer") { Scraper::Importer.new(theater: theater).import(normalized) }
        end

        def day_label(movie)
          URI(movie[:url]).path.delete("/").tr("-", " ").capitalize
        end
      end
    end
  end
end
