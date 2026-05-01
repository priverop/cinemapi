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

        title.strip # TODO: Renoir always have UPPERCASE MOVIE TITLES, we should normalize that as well.
      end

      def normalize_directors(directors)
        return [] if directors.nil? || directors.strip.empty?

        directors.sub("de", "").strip.split(", ")
      end

      def normalize_language(language)
        if language.nil? || language.strip.empty?
          Scraper.logger.warn("Could not normalize language: #{language.inspect}.")
          return nil
        end

        normalized = language.downcase.strip
        language_symbol = LANGUAGE_MAP.find { |regex, _| normalized.match?(regex) }&.last

        raise Scraper::UnknownLanguageError, "Unkown language '#{language}'." if language_symbol.nil?

        language_symbol
      end

      def normalize_duration(duration)
        return nil if duration.nil? || duration.strip.empty?

        duration[DURATION_REGEX]&.to_i
      end

      def normalize_showtimes(showtimes)
        return [] if showtimes.nil? || showtimes.empty? # || showtimes.all? { |s| s.empty? }

        showtimes.map { |s| { date: Time.strptime("#{date} #{s.strip}", "%Y-%m-%d %H:%M") } }
      end
    end
  end
end
