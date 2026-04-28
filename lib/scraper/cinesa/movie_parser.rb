# frozen_string_literal: true

require "json"

module Scraper
  module Cinesa
    #https://film-cdn.moviexchange.com/api/cdn/release/<moviexchangeReleaseId>/media/Poster?width=400
    # Parses the movies of a single page.
    class MovieParser
      attr_reader :json

      def initialize(input)
        @json = JSON.parse(input)
      end

      def parse
        parsed_movies = []
        movies.each do |movie|
          parsed_movies << {
            description: movie_description(movie),
            directors: movie_director(movie),
            duration: movie_duration(movie),
            genre: movie_genre(movie),
            poster_id: movie_poster(movie),
            showtimes: movie_showtimes(movie),
            title: movie_title(movie),
            trailer: movie_trailer(movie)
          }
        end
        Scraper.logger.info("Parsed #{parsed_movies.size} movies from page.")
        parsed_movies
      end

      private

      def movies
        scraped_movies = json["relatedData"]["films"]

        raise Scraper::MoviesNotFoundError, "Movies not found." if scraped_movies.nil? || scraped_movies.empty?

        scraped_movies
      end

      def movie_poster(movie)
        movie["externalIds"]["moviexchangeReleaseId"]
      end

      def movie_title(movie)
        movie["title"]["text"]
      end

      def movie_genre(movie)
        movie["genreIds"].map do |g_id|
          json["relatedData"]["genres"].find { |genre| genre["id"] == g_id }&.dig("name", "text")
        end
      end

      def movie_description(movie)
        movie["synopsis"]["text"]
      end

      def movie_trailer(movie)
        movie["trailerUrl"]
      end

      def movie_duration(movie)
        movie["runtimeInMinutes"]
      end

      def movie_director(movie)
        movie["castAndCrew"].filter_map do |member|
          json["relatedData"]["castAndCrew"].find { |c| c["id"] == member["castAndCrewMemberId"] if member["roles"].include?("Director") }&.dig("name")
        end
      end

      def movie_showtimes(movie)
        showtimes = json["showtimes"].select { |showtime| showtime["filmId"] == movie["id"]  }
        showtimes.map do |st|
          {
            date: st["schedule"]["startsAt"],
            language: showtime_language(st["attributeIds"])
          }
        end
      end

      def showtime_language(language_ids)
        language_ids.map do |l_id|
          json["relatedData"]["attributes"].find { |attribute| attribute["id"] == l_id  }&.dig("name", "text")
        end
      end
    end
  end
end
