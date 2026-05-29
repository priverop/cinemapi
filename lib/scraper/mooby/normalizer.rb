# frozen_string_literal: true

require "time"
require_relative "../normalizer_helpers"

module Scraper
  module Mooby
    class Normalizer
      include Scraper::NormalizerHelpers

      # Order matters: DOBLADA is matched before ESP/CAT so "DOBLADA CAT" maps to
      # :dubbed, not :vo. VOSE covers its ATMOS variant via the anchor. VOSI is
      # intentionally absent: it only appears on Eventos (concerts, already
      # skipped), so a real VOSI film should raise UnknownLanguageError loudly.
      LANGUAGE_MAP = {
        /\Adoblada/i => :dubbed,
        /\Avose/i    => :vose,
        /\Aesp/i     => :vo,
        /\Acat/i     => :vo
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
        raise Scraper::InvalidMovieError, "Movie has an empty title." if title.nil? || title.strip.empty?

        title.gsub(/\((?:VOSE|VOSC|VO|DOBLADA[^)]*|CAT|ESP)\)/i, "").strip.squeeze(" ")
      end

      def normalize_directors(directors)
        split_list(directors)
      end

      def normalize_genres(genres)
        split_list(genres)
      end

      def normalize_duration(duration)
        return nil if duration.nil? || duration.to_s.strip.empty?

        duration[DURATION_REGEX]&.to_i
      end

      def normalize_description(description)
        return nil if description.nil?

        cleaned = description.strip.squeeze(" ")
        cleaned.empty? ? nil : cleaned
      end

      def split_list(value)
        return [] if value.nil? || value.to_s.strip.empty?

        value.to_s.split(",").map(&:strip).reject(&:empty?)
      end

      def normalize_showtimes(showtimes)
        Array(showtimes).map do |st|
          {
            date: Time.strptime("#{st[:date].to_s.strip} +0000", "#{DATE_FORMAT} %z"),
            language: normalize_language_from_map(st[:language], LANGUAGE_MAP)
          }
        end
      end
    end
  end
end
