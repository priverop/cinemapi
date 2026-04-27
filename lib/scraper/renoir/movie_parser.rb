# frozen_string_literal: true

require "nokogiri"

module Scraper
  module Renoir
    # Parses the movies of a single page.
    class MovieParser
      attr_reader :document

      CSS_SELECTORS = {
        movie_container: ".my-account-content.d-lg-block",
        movie_poster: "a[data-toggle='lightbox']",
        movie_title: "a[href^='/pelicula/']",
        movie_directors: "small > b",
        movie_duration: "small:contains('Duración')",
        movie_language: "small:contains('Versión')",
        movie_showtimes: ".pase-cartelera a[href^='http']" # there are modals in this page, so we need to check for http
      }

      def initialize(html)
        @document = Nokogiri::HTML(html)
      end

      def parse
        parsed_movies = []
        movies.each do |movie|
          parsed_movies << {
            poster: movie_poster(movie),
            title: movie_title(movie),
            directors: movie_directors(movie),
            language: movie_language(movie),
            duration: movie_duration(movie),
            showtimes: movie_showtimes(movie)
          }
        end
        Scraper.logger.info("Parsed #{parsed_movies.size} movies from page.")
        parsed_movies
      end

      private

      def movies
        scraped_movies = document.css(CSS_SELECTORS[:movie_container])

        raise Scraper::MoviesNotFoundError, "Movies not found." if scraped_movies.empty?

        scraped_movies
      end

      def movie_poster(movie)
        movie.at_css(CSS_SELECTORS[:movie_poster])[ "href" ]
      end

      def movie_title(movie)
        movie.at_css(CSS_SELECTORS[:movie_title])&.text
      end

      def movie_directors(movie)
        movie.at_css(CSS_SELECTORS[:movie_directors])&.text
      end

      def movie_language(movie)
        movie.at_css(CSS_SELECTORS[:movie_language])&.text
      end

      def movie_duration(movie)
        movie.at_css(CSS_SELECTORS[:movie_duration])&.text
      end

      def movie_showtimes(movie)
        movie.css(CSS_SELECTORS[:movie_showtimes])&.map do |showtime|
          showtime&.text
        end
      end
    end
  end
end
