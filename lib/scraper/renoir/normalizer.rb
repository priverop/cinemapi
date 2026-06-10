# frozen_string_literal: true

require "uri"
require "time"
require_relative "../normalizer_helpers"

module Scraper
  module Renoir
    class Normalizer
      include Scraper::NormalizerHelpers

      attr_reader :date

      LANGUAGE_MAP = {
        /subtitulada/ => :vose,
        /versi[oó]n original/ => :vo
      }.freeze

      DURATION_REGEX = /\d+/

      def initialize(date)
        @date = date
      end

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

        Scraper.logger.info("Normalizing #{input.size} movies for #{date}.")
        input.map { |movie| normalize_movie(movie) }
      end

      private

      def normalize_movie(movie)
        normalized_movie = {}
        movie.each do |key, value|
          normalized_movie[key] = send("normalize_#{key}", value)
        end
        normalized_movie
      end

      def normalize_poster(poster)
        normalize_poster_url(poster)
      end

      def normalize_title(title)
        canonicalize_title(title)
      end

      def normalize_directors(directors)
        return [] if directors.nil? || directors.strip.empty?

        directors.sub("de", "").strip.split(", ")
      end

      def normalize_language(language)
        normalize_language_from_map(language&.downcase, LANGUAGE_MAP)
      end

      def normalize_duration(duration)
        return nil if duration.nil? || duration.strip.empty?

        duration[DURATION_REGEX]&.to_i
      end

      def normalize_showtimes(showtimes)
        return [] if showtimes.nil? || showtimes.empty? # || showtimes.all? { |s| s.empty? }

        showtimes.map { |s| { date: Time.strptime("#{date} #{s.strip} +0000", "%Y-%m-%d %H:%M %z") } }
      end
    end
  end
end
