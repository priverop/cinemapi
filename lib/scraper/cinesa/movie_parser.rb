# frozen_string_literal: true

require "json"

module Scraper
  module Cinesa
    # Parses the movies of a single page.
    class MovieParser
      attr_reader :json

      def initialize(input)
        @json = JSON.parse(input)
      end

      def parse
        movies = movies_to_parse
        Scraper.logger.info("Parsing #{movies.size} movies from page.")
        movies.map do |movie|
          {
            description: movie_description(movie),
            directors: movie_directors(movie),
            duration: movie_duration(movie),
            genres: movie_genres(movie),
            poster_id: movie_poster(movie),
            showtimes: movie_showtimes(movie),
            title: movie_title(movie),
            trailer: movie_trailer(movie)
          }
        end
      end

      private

      def movies_to_parse
        scraped_movies = json.dig("relatedData", "films")

        raise Scraper::MoviesNotFoundError, "Movies not found." if scraped_movies.nil? || scraped_movies.empty?

        scraped_movies
      end

      def movie_poster(movie)
        movie.dig("externalIds", "moviexchangeReleaseId")
      end

      def movie_title(movie)
        movie.dig("title", "text")
      end

      def movie_genres(movie)
        return [] unless movie["genreIds"]

        movie["genreIds"].map do |g_id|
          json.dig("relatedData", "genres")&.find { |genre| genre["id"] == g_id }&.dig("name", "text")
        end
      end

      def movie_description(movie)
        movie.dig("synopsis", "text")
      end

      def movie_trailer(movie)
        movie["trailerUrl"]
      end

      def movie_duration(movie)
        movie["runtimeInMinutes"]
      end

      def movie_directors(movie)
        return [] unless movie["castAndCrew"]

        movie["castAndCrew"].filter_map do |member|
          next unless member.dig("roles")&.include?("Director")

          json.dig("relatedData", "castAndCrew")&.find { |c| c["id"] == member["castAndCrewMemberId"] }&.dig("name")
        end
      end

      def movie_showtimes(movie)
        return [] unless json["showtimes"]

        showtimes = json["showtimes"].select { |showtime| showtime["filmId"] == movie["id"] }
        showtimes.map do |st|
          {
            date: st.dig("schedule", "startsAt"),
            language: showtime_language(st["attributeIds"])
          }
        end
      end

      def showtime_language(language_ids)
        return [] unless language_ids

        language_ids.map do |l_id|
          json.dig("relatedData", "attributes")&.find { |attribute| attribute["id"] == l_id }&.dig("name", "text")
        end
      end
    end
  end
end
