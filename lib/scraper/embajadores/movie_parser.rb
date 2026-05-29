# frozen_string_literal: true

require "nokogiri"

module Scraper
  module Embajadores
    class MovieParser
      attr_reader :document

      CSS_SELECTORS = {
        movie_container: "ul.cartelera.cartelera-home li.movie",
        poster:          "div.poster img",
        title:           "div.info h2 a",
        director:        "div.more h5:first-child",
        duration:        "li.minutos",
        language:        "li.doblaje",
        showtime_span:   "span[data-hora]"
      }.freeze

      def initialize(html)
        @document = Nokogiri::HTML(html)
      end

      def parse
        movies = document.css(CSS_SELECTORS[:movie_container])
        raise Scraper::MoviesNotFoundError, "Movies not found." if movies.empty?

        Scraper.logger.info("Parsed #{movies.size} movies from page.")
        movies.map { |movie| parse_movie(movie) }
      end

      private

      def parse_movie(movie)
        {
          poster:    movie.at_css(CSS_SELECTORS[:poster])&.[]("src"),
          title:     movie.at_css(CSS_SELECTORS[:title])&.text,
          director:  parse_director(movie),
          duration:  movie.at_css(CSS_SELECTORS[:duration])&.text,
          language:  movie.at_css(CSS_SELECTORS[:language])&.text,
          showtimes: parse_showtimes(movie)
        }
      end

      def parse_director(movie)
        text = movie.at_css(CSS_SELECTORS[:director])&.text
        return nil if text.nil?

        text.sub(/\ADirector\s*:?\s*/i, "").strip
      end

      def parse_showtimes(movie)
        movie.css(CSS_SELECTORS[:showtime_span]).filter_map do |span|
          link = span.at_css("a.compraTicket")
          next if link.nil?

          { time: span["data-hora"], url: link["href"] }
        end
      end
    end
  end
end
