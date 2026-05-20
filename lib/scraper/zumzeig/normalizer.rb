# frozen_string_literal: true

require_relative "../normalizer_helpers"

module Scraper
  module Zumzeig
    class Normalizer
      include Scraper::NormalizerHelpers

      LANGUAGE_MAP = {
        /vose|voscat|vosc\b/i => :vose,
        /doblad[ao]/i => :dubbed,
        /\bvo\b/i => :vo
      }.freeze

      DURATION_REGEX = /\d+/

      def initialize(base_url: nil)
        @base_url = base_url
      end

      def normalize(input)
        raise ArgumentError, "Input should be an array." unless input.is_a?(Array)
        raise ArgumentError, "Input array is empty." if input.empty?

        Scraper.logger.info("Normalizing #{input.size} movies.")
        input.map { |movie| normalize_movie(movie) }
      end

      private

      attr_reader :base_url

      def normalize_movie(movie)
        {
          title: normalize_title(movie[:title]),
          directors: normalize_directors(movie[:directors]),
          duration: normalize_duration(movie[:duration]),
          language: normalize_language(movie[:language]),
          description: movie[:description],
          poster: normalize_poster_url(movie[:poster], base_url: base_url),
          genres: movie[:genres] || [],
          showtimes: normalize_showtimes(movie[:showtimes])
        }
      end

      def normalize_title(title)
        raise Scraper::InvalidMovieError, "Movie has an empty title." if title.nil? || title.strip.empty?

        title.strip
      end

      def normalize_directors(directors)
        return [] if directors.nil? || (directors.respond_to?(:strip) && directors.strip.empty?)
        return directors if directors.is_a?(Array)

        directors.split(",").map(&:strip).reject(&:empty?)
      end

      def normalize_duration(duration)
        return nil if duration.nil? || duration.to_s.strip.empty?

        duration.to_s[DURATION_REGEX]&.to_i
      end

      def normalize_language(language)
        normalize_language_from_map(language, LANGUAGE_MAP)
      end

      def normalize_showtimes(showtimes)
        return [] if showtimes.nil? || showtimes.empty?

        showtimes.map { |t| { date: t } }
      end
    end
  end
end
