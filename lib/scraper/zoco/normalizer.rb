# frozen_string_literal: true

require "time"
require_relative "../normalizer_helpers"

module Scraper
  module Zoco
    class Normalizer
      include Scraper::NormalizerHelpers

      LANGUAGE_MAP = {
        /con subt[ií]tulos/i => :vose,
        /\Adob[a-z]*lada/i   => :dubbed,
        /\Aoriginal/i        => :vo
      }.freeze

      DURATION_REGEX    = /\d+/
      TITLE_SUFFIX      = /\s*(VOSE|V\.O\.S\.?E?\.?)\s*\z/i

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
          directors:   normalize_directors(movie[:directors]),
          duration:    normalize_duration(movie[:duration]),
          description: normalize_description(movie[:description]),
          language:    normalize_language(movie[:language]),
          showtimes:   normalize_showtimes(movie[:showtimes])
        }
      end

      def normalize_title(title)
        raise Scraper::InvalidMovieError, "Movie has an empty title." if title.nil? || title.strip.empty?

        title.sub(TITLE_SUFFIX, "").strip
      end

      def normalize_directors(directors)
        return [] if directors.nil? || directors.to_s.strip.empty?

        directors.to_s.split(",").map(&:strip).reject(&:empty?)
      end

      def normalize_duration(duration)
        return nil if duration.nil? || duration.to_s.strip.empty?

        duration.to_s[DURATION_REGEX]&.to_i
      end

      def normalize_description(description)
        return nil if description.nil?

        cleaned = description.strip.squeeze(" ")
        cleaned.empty? ? nil : cleaned
      end

      def normalize_language(language)
        normalize_language_from_map(language, LANGUAGE_MAP)
      end

      def normalize_showtimes(showtimes)
        return [] if showtimes.nil? || showtimes.empty?

        showtimes.map do |st|
          { date: Time.strptime("#{st[:date]} #{st[:time]} +0000", "%d-%m-%Y %H:%M %z") }
        end
      end
    end
  end
end
