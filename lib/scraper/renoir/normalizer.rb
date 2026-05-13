# frozen_string_literal: true

require "uri"
require "time"

module Scraper
  module Renoir
    class Normalizer
      attr_reader :date

      LANGUAGE_MAP = {
        /subtitulada/ => :vose,
        /versi[oó]n original/ => :vo
      }

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
        return nil if poster.nil? || poster.strip.empty?
        return poster if Scraper.valid_http_url?(poster)

        Scraper.logger.warn("Could not normalize poster: #{poster.inspect}.")
        nil
      end

      def normalize_title(title)
        raise Scraper::InvalidMovieError, "Movie has an empty title." if title.nil? || title.strip.empty?

        title.gsub(/\[.*?\]/, "").strip.titleize
      end

      def normalize_directors(directors)
        return [] if directors.nil? || directors.strip.empty?

        directors.sub("de", "").strip.split(", ")
      end

      def normalize_language(language)
        raise Scraper::UnknownLanguageError, "Unknown language #{language.inspect}." if language.nil? || language.strip.empty?

        normalized = language.downcase.strip
        result = LANGUAGE_MAP.find { |regex, _| normalized.match?(regex) }&.last
        raise Scraper::UnknownLanguageError, "Unknown language '#{language}'." if result.nil?

        result
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
