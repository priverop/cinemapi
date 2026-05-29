# frozen_string_literal: true

require "uri"

module Scraper
  module Ocine
    # Single-fetch orchestrator: Ocine exposes the full cartelera (all
    # movies, all dates) as one JSON document. No per-day or per-movie
    # fetching is needed, so this does not inherit from BaseOrchestrator.
    class Orchestrator
      CARTELERA_PATH = "/components/com_cines/json/es_cartellera.json"

      class << self
        def run(theater)
          base_url = URI(theater.website)
          url      = base_url.merge(CARTELERA_PATH)

          Scraper.logger.info("Starting scrape for #{base_url}.")
          raw        = Scraper.logger.tagged("Client")      { Scraper::Client.read(url) }
          parsed     = Scraper.logger.tagged("MovieParser") { Scraper::Ocine::MovieParser.new(raw).parse }
          normalized = Scraper.logger.tagged("Normalizer")  { Scraper::Ocine::Normalizer.new(base_url: base_url).normalize(parsed) }
          Scraper.logger.tagged("Importer") { Scraper::Importer.new(theater: theater).import(normalized) }
          Scraper.logger.info("Done.")
        end
      end
    end
  end
end
