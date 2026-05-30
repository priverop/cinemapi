# frozen_string_literal: true

require "time"
require_relative "../normalizer_helpers"

module Scraper
  module Mk2
    class Normalizer
      include Scraper::NormalizerHelpers

      BASE_URL       = "https://www.cinepazmadrid.es/"
      DURATION_REGEX = /\d+/

      attr_reader :date

      def initialize(date)
        @date = date
      end

      def normalize(input)
        raise ArgumentError, "Input should be an array." unless input.is_a?(Array)
        raise ArgumentError, "Input array is empty." if input.empty?

        Scraper.logger.info("Normalizing #{input.size} movies for #{date}.")
        input.map { |movie| normalize_movie(movie) }
      end

      private

      def normalize_movie(movie)
        {
          title:     normalize_title(movie[:title]),
          directors: normalize_director(movie[:director]),
          duration:  normalize_duration(movie[:duration]),
          language:  movie[:language],
          poster:    normalize_poster(movie[:poster]),
          showtimes: normalize_showtimes(movie[:showtimes])
        }
      end

      def normalize_title(title)
        canonicalize_title(title)
      end

      def normalize_director(director)
        return [] if director.nil? || director.strip.empty?

        [ director.sub(/\Ade\s+/i, "").strip ]
      end

      def normalize_duration(duration)
        return nil if duration.nil? || duration.strip.empty?

        duration[DURATION_REGEX]&.to_i
      end

      def normalize_poster(poster)
        normalize_poster_url(poster, base_url: BASE_URL)
      end

      def normalize_showtimes(showtimes)
        return [] if showtimes.nil? || showtimes.empty?

        showtimes.map { |s| { date: Time.strptime("#{date} #{s.strip} +0000", "%Y-%m-%d %H:%M %z") } }
      end
    end
  end
end
