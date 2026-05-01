# frozen_string_literal: true

require "uri"
require "time"

module Scraper
  module Cinesa
    class Normalizer
      POSTER_URL = "https://film-cdn.moviexchange.com/api/cdn/release/{poster_id}/media/Poster"

      class << self
        #
        # Cleans every value of the movies. Removes trailspaces, unknown characters, etc.
        #
        # @param [Array<Hash>] input not clean movies.
        #
        # @return [Array<Hash>] clean movies.
        #
        def normalize(input)
          raise ArgumentError, "Input should be an array." unless input.is_a?(Array)
          raise ArgumentError, "Input array is empty." if input.empty?

          Scraper.logger.info("Normalizing #{input.size} movies.")
          input.map { |movie| normalize_movie(movie) }
        end

        private

        def normalize_movie(movie)
          {
            title: normalize_title(movie[:title]),
            description: normalize_description(movie[:description]),
            directors: normalize_directors(movie[:directors]),
            duration: normalize_duration(movie[:duration]),
            genres: normalize_genres(movie[:genres]),
            poster: normalize_poster(movie[:poster_id]),
            showtimes: normalize_showtimes(movie[:showtimes]),
            trailer: normalize_trailer(movie[:trailer])
          }
        end

        def normalize_description(description)
          return nil if description.nil? || description.strip.empty?

          description.strip
        end

        def normalize_directors(directors)
          return [] if directors.nil? || directors.empty?

          directors.map { |director| "#{director["givenName"]} #{director["familyName"]}" }
        end

        def normalize_duration(duration)
          return nil if duration.nil? || !duration.is_a?(Integer)

          duration
        end

        def normalize_genres(genres)
          return [] if genres.nil? || genres.empty?

          genres.map { |genre| genre.strip }
        end

        def normalize_poster(poster_id)
          return nil if poster_id.nil? || poster_id.empty?

          POSTER_URL.sub("{poster_id}", poster_id)
        end

        def normalize_showtimes(showtimes)
          return [] if showtimes.nil? || showtimes.empty? # || showtimes.all? { |s| s.empty? }

          showtimes.map { |s| { date: normalize_date(s[:date]), language: normalize_language(s[:language]) } }
        end

        def normalize_date(date)
          return nil if date.nil? || date.empty?

          DateTime.parse(date)
        end

        def normalize_language(languages)
          return nil if languages.nil?

          languages.include?("Vose") ? :vose : :dubbed # TODO: we need to figure something out for dubbed vs VO (spanish)
        end

        def normalize_title(title)
          raise Scraper::InvalidMovieError, "Movie has an empty title." if title.nil? || title.strip.empty?

          title.strip
        end

        def normalize_trailer(trailer)
          return nil if trailer.nil? || trailer.strip.empty?
          return trailer if Scraper.valid_http_url?(trailer)

          Scraper.logger.warn("Could not normalize trailer: #{trailer.inspect}.")
          nil
        end
      end
    end
  end
end
