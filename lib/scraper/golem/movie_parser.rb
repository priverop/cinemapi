# frozen_string_literal: true

require "nokogiri"

module Scraper
  module Golem
    # Parses movies on a single Golem day page.
    class MovieParser
      attr_reader :document

      CSS_SELECTORS = {
        movie_container: "table[background='#AEAEAE']",
        title:           "a.txtNegXXL[href^='/golem/pelicula/']",
        poster:          "img.bordeCartel",
        showtime:        "a.horaXXXL"
      }.freeze

      VOSE_MARKER = /\(V\.O\.S\.E\.\)/i

      def initialize(html)
        @document = Nokogiri::HTML(html)
      end

      def parse
        movies = document.css(CSS_SELECTORS[:movie_container]).select do |m|
          m.at_css(CSS_SELECTORS[:title])
        end
        raise Scraper::MoviesNotFoundError, "Movies not found." if movies.empty?

        parsed = movies.map { |m| parse_movie(m) }
        Scraper.logger.info("Parsed #{parsed.size} movies from page.")
        parsed
      end

      private

      def parse_movie(movie)
        title_link = movie.at_css(CSS_SELECTORS[:title])
        title = title_link&.text.to_s.strip
        {
          poster:     movie.at_css(CSS_SELECTORS[:poster])&.[]("src"),
          title:      title,
          detail_url: title_link&.[]("href"),
          language:   title.match?(VOSE_MARKER) ? "vose" : "vo",
          showtimes:  movie.css(CSS_SELECTORS[:showtime]).map { |a| a.text.strip }.uniq
        }
      end
    end
  end
end
