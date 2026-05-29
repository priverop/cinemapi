# frozen_string_literal: true

require "json"

module Scraper
  module Ocine
    # Parses the Ocine cartelera JSON payload. The endpoint returns two
    # disjoint arrays of currently-screened movies — `data` (dubbed/regular)
    # and `vose` (original-version-with-subtitles) — plus `estrenos`
    # (upcoming releases without showtimes, which we ignore).
    class MovieParser
      attr_reader :raw

      def initialize(raw)
        @raw = raw
      end

      def parse
        payload = JSON.parse(raw)
        data = Array(payload["data"])
        vose = Array(payload["vose"])

        movies = data.map { |m| build_movie(m, :dubbed) } +
                 vose.map { |m| build_movie(m, :vose) }

        raise Scraper::MoviesNotFoundError, "Movies not found." if movies.empty?

        Scraper.logger.info("Parsed #{movies.size} movies from cartelera.")
        movies
      rescue JSON::ParserError => e
        raise Scraper::MoviesNotFoundError, "Invalid cartelera JSON: #{e.message}."
      end

      private

      def build_movie(raw_movie, language)
        {
          movie_id:    raw_movie["peli_pelicula"],
          title:       raw_movie["peli_titol"],
          duration:    raw_movie["peli_durada"],
          genre:       raw_movie["peli_generacomercial"],
          description: raw_movie.dig("Pelicules2", "pel2_sinopsis"),
          language:    language,
          showtimes:   parse_showtimes(raw_movie["Planificacions"])
        }
      end

      def parse_showtimes(plans)
        Array(plans).map { |p| { date: p["plan_data"], time: p["plan_horainici"] } }
      end
    end
  end
end
