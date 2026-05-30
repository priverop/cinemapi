# frozen_string_literal: true

require "time"
require_relative "../normalizer_helpers"

module Scraper
  module CinesAbc
    class Normalizer
      include Scraper::NormalizerHelpers

      VOSE_REGEX     = /VOSE/i
      DURATION_REGEX = /\d+/
      TIME_SUFFIX    = /h\z/i
      DATE_REGEX     = %r{\A\d{2}/\d{2}/\d{4}\z}
      TIME_REGEX     = /\A\d{1,2}:\d{2}\z/

      def normalize(input)
        raise ArgumentError, "Input should be an array." unless input.is_a?(Array)
        raise ArgumentError, "Input array is empty." if input.empty?

        Scraper.logger.info("Normalizing #{input.size} movies.")
        input.map { |movie| normalize_movie(movie) }
      end

      private

      def normalize_movie(movie)
        {
          title:       normalize_title(movie[:title]),
          poster:      normalize_poster_url(movie[:poster]),
          description: normalize_description(movie[:description]),
          duration:    normalize_duration(movie[:duration]),
          genres:      movie[:genres] || [],
          showtimes:   normalize_showtimes(movie[:showtimes])
        }
      end

      def normalize_title(title)
        canonicalize_title(title)
      end

      def normalize_description(description)
        return nil if description.nil?

        cleaned = description.strip.squeeze(" ")
        cleaned.empty? ? nil : cleaned
      end

      def normalize_duration(duration)
        return nil if duration.nil? || duration.to_s.strip.empty?

        duration.to_s[DURATION_REGEX]&.to_i
      end

      def normalize_showtimes(showtimes)
        return [] if showtimes.nil? || showtimes.empty?

        showtimes.filter_map do |st|
          date = st[:date].to_s
          time = st[:time].to_s.sub(TIME_SUFFIX, "")
          next nil unless date.match?(DATE_REGEX) && time.match?(TIME_REGEX)

          {
            date:     Time.strptime("#{date} #{time} +0000", "%d/%m/%Y %H:%M %z"),
            language: normalize_language(st[:language])
          }
        end
      end

      def normalize_language(value)
        value.to_s.match?(VOSE_REGEX) ? :vose : :dubbed
      end
    end
  end
end
