# frozen_string_literal: true

require "uri"
require_relative "../base_orchestrator"

module Scraper
  module VerdiBarcelona
    # Verdi Barcelona is an Alpine.js SPA: the cartelera page lists movies that
    # lazy-load their data from a JSON API. We treat each movie (imdbid) as one
    # work-unit, fetching and importing it independently so a single bad movie
    # does not abort the rest. The poster only exists in the listing, so we read
    # it there and inject it into the parsed movie before normalizing.
    class Orchestrator < Scraper::BaseOrchestrator
      API_PATH = "/api/get-event-by-imdbid"

      class << self
        private

        def calendar_days(theater)
          html = Scraper.logger.tagged("Client") { Scraper::Client.read(URI(theater.website)) }
          Scraper.logger.tagged("ListParser") { Scraper::VerdiBarcelona::ListParser.new(html).movies }
        end

        def process_day(theater, entry)
          url        = movie_api_url(theater.website, entry[:imdbid])
          json       = Scraper.logger.tagged("Client") { Scraper::Client.read(url) }
          parsed     = Scraper.logger.tagged("MovieParser") { Scraper::VerdiBarcelona::MovieParser.new(json).parse }
          if parsed[:showtimes].empty?
            Scraper.logger.info("Skipping movie with no cinema events.")
            return
          end
          parsed[:poster] = entry[:poster]
          normalized = Scraper.logger.tagged("Normalizer") { Scraper::VerdiBarcelona::Normalizer.new.normalize([ parsed ]) }
          Scraper.logger.tagged("Importer") { Scraper::Importer.new(theater: theater).import(normalized) }
        end

        def day_label(entry) = entry[:slug].to_s.delete_prefix("/").presence || entry[:imdbid]

        def movie_api_url(website, imdbid)
          base = URI(website)
          URI("#{base.scheme}://#{base.host}#{API_PATH}/#{imdbid}")
        end
      end
    end
  end
end
