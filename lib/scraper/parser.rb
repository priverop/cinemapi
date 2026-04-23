# frozen_string_literal: true

require "nokogiri" # TODO: ADD

module Scraper
  # Parses the HTML into Ruby objects.
  class Parser
    CSS_SELECTORS = {
      movie_container: ".my-account-content.d-lg-block",
      movie_poster: "a[data-toggle='lightbox']",
      movie_title: ".col-4 > a",
      movie_director: "small:first-of-type > b",
      movie_duration: "small:nth-of-type(3)",
      movie_language: "small:nth-of-type(2)",
      movie_showtimes: ".my-movie-content.lg-block"
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
          director: movie_director(movie),
          language: movie_language(movie),
          duration: movie_duration(movie)
        }
      end
      parsed_movies
    end

    private

    def movies
      scraped_movies = @document.css(CSS_SELECTORS[:movie_container])

      raise Scraper::MoviesNotFoundError, "Movies not found." if scraped_movies.empty?

      scraped_movies
    end

    def movie_poster(movie)
      movie.at_css(CSS_SELECTORS[:movie_poster])[ "href" ]
    end

    def movie_title(movie)
      movie.at_css(CSS_SELECTORS[:movie_title])&.text
    end

    def movie_director(movie)
      movie.at_css(CSS_SELECTORS[:movie_director])&.text
    end

    def movie_language(movie)
      movie.at_css(CSS_SELECTORS[:movie_language])&.text
    end

    def movie_duration(movie)
      movie.at_css(CSS_SELECTORS[:movie_duration])&.text
    end

    def movie_showtimes(movie)
      movie.css(CSS_SELECTORS[:movie_showtimes]).map do |showtime|
        showtime  # TODO
      end
    end
  end
end
