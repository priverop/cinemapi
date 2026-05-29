# frozen_string_literal: true

require "time"
require_relative "../normalizer_helpers"

module Scraper
  module AdmitOne
    class Normalizer
      include Scraper::NormalizerHelpers

      LANGUAGE_MAP = {
        /v\.?o\.?\s*sub/i        => :vose,
        /^vose$/i                => :vose,
        /^vosc$/i                => :vose,
        /^vosi$/i                => :vosi,
        /^castellano$/i          => :vo,
        /^castell[aàÀÁ]$/iu      => :vo,
        /^catal[aàÀÁ]$/iu        => :vo,
        /^dig$/i                 => :vo,
        /^varios$/i              => :vo
      }.freeze

      DURATION_REGEX = /\d+/
      DATE_FORMAT    = "%Y%m%d %H:%M"

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

        title.gsub(/\(VOSE\)|\(VOSC\)|\(VO\)/i, "").strip.squeeze(" ").titleize
      end

      def normalize_directors(directors)
        return [] if directors.nil? || directors.strip.empty?

        directors.strip.split(",").map(&:strip).reject(&:empty?)
      end

      def normalize_duration(duration)
        return nil if duration.nil? || duration.strip.empty?

        duration[DURATION_REGEX]&.to_i
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
