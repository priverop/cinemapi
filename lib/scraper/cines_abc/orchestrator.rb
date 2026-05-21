# frozen_string_literal: true

require "uri"
require_relative "../base_orchestrator"

module Scraper
  module CinesAbc
    # Cines ABC chain (El Saler, Park, Gran Turia, Elx, Gandía). One scraper
    # parametrized by Theater#website covers all subdomains since the engine
    # is identical: cartelera page lists movies, each links to a ficha page
    # containing all showtimes for that movie.
    class Orchestrator < Scraper::BaseOrchestrator
      class << self
        private

        def calendar_days(theater)
          base_url = URI(theater.website)
          html     = Scraper.logger.tagged("Client") { Scraper::Client.read(base_url) }
          Scraper.logger.tagged("ListParser") { Scraper::CinesAbc::ListParser.new(html).movies }
        end

        def process_day(theater, movie)
          url        = URI(movie[:url])
          html       = Scraper.logger.tagged("Client") { Scraper::Client.read(url) }
          parsed     = Scraper.logger.tagged("MovieParser") { Scraper::CinesAbc::MovieParser.new(html).parse }
          normalized = Scraper.logger.tagged("Normalizer") { Scraper::CinesAbc::Normalizer.new.normalize([ parsed ]) }
          Scraper.logger.tagged("Importer") { Scraper::Importer.new(theater: theater).import(normalized) }
        end

        def day_label(movie)
          title = movie[:title].to_s.strip
          title.empty? ? URI(movie[:url]).query.to_s : title
        end
      end
    end
  end
end
