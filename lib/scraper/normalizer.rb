# frozen_string_literal: true

require "uri"

module Scraper
  class Normalizer
    LANGUAGE_MAP = {
      /subtitulada/ => :vose,
      /versi[oó]n original/ => :vo
    }

    DURATION_REGEX = /\d+/

    class << self
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

        input.map do |movie|
          normalize_movie(movie)
        end
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

        poster_url = URI.parse(poster)
        return nil unless poster_url.is_a?(URI:HTTP) && poster_url.host.present?

        poster_url
      end

      def normalize_title(title)
        return nil if title.nil? || title.strip.empty? 

        title.strip # TODO: Falta hacer lo de la capitalizacion
      end

      def normalize_directors(directors)
        return nil if directors.nil? || directors.strip.empty? 

        directors.gsub("de", "").strip.split(", ")
      end

      def normalize_language(language)
        return nil if language.nil? || language.strip.empty? 

        normalized = language.downcase.strip

        language_symbol = LANGUAGE_MAP.find { |regex, symbol| normalized.match?(regex) }&.last

        raise UnknownLanguageError, "Unkown language '#{language}'." unless language_symbol.present?
        
        language_symbol
      end

      def normalize_duration(duration)
        return nil if duration.nil? || duration.strip.empty? 

        duration[DURATION_REGEX]&.to_i
      end
    end
  end
end
