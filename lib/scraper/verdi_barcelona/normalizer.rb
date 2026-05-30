# frozen_string_literal: true

require "time"
require_relative "../normalizer_helpers"

module Scraper
  module VerdiBarcelona
    # Cleans and coerces the parsed Verdi Barcelona movie data. Language is
    # derived from the event "version" string. Verdi is an arthouse cinema with
    # no dubbed films: foreign films are subtitled (:vose) and Spanish/Catalan
    # films play in their original language (:vo). See docs/languages.md.
    class Normalizer
      include Scraper::NormalizerHelpers

      LANGUAGE_MAP = {
        /v\.?o\.?\s*sub/i       => :vose,
        /\Acastellano\z/i       => :vo,
        /\Acatal[aáàÀÁ]n\z/iu   => :vo,
        /\Avarios\z/i           => :vo
      }.freeze

      DURATION_REGEX = /\d+/
      DATE_FORMAT    = "%Y%m%d%H%M%S"

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
          directors: normalize_directors(movie[:directors]),
          duration: normalize_duration(movie[:duration]),
          genres: normalize_genres(movie[:genres]),
          poster: normalize_poster_url(movie[:poster]),
          description: normalize_description(movie[:description]),
          language: nil,
          showtimes: normalize_showtimes(movie[:showtimes])
        }
      end

      def normalize_title(title)
        canonicalize_title(title)
      end

      def normalize_directors(directors)
        Array(directors).map(&:strip).reject(&:empty?)
      end

      def normalize_duration(duration)
        return nil if duration.nil? || duration.to_s.strip.empty?

        duration.to_s[DURATION_REGEX]&.to_i
      end

      def normalize_genres(genres)
        Array(genres).map(&:strip).reject(&:empty?)
      end

      def normalize_description(description)
        return nil if description.nil?

        cleaned = description.strip.squeeze(" ")
        cleaned.empty? ? nil : cleaned
      end

      def normalize_showtimes(showtimes)
        Array(showtimes).map do |showtime|
          {
            date: Time.strptime("#{showtime[:date].to_s.strip} +0000", "#{DATE_FORMAT} %z"),
            language: normalize_language_from_map(showtime[:language], LANGUAGE_MAP)
          }
        end
      end
    end
  end
end
