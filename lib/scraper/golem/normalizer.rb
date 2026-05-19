# frozen_string_literal: true

require "uri"
require "time"
require_relative "../normalizer_helpers"

module Scraper
  module Golem
    class Normalizer
      include Scraper::NormalizerHelpers

      attr_reader :date, :base_url

      LANGUAGE_MAP = {
        "vose" => :vose,
        "vo"   => :vo
      }.freeze

      VOSE_SUFFIX = /\s*\(V\.O\.S\.E\.\)\s*\z/i

      def initialize(date:, base_url:)
        @date = date
        @base_url = base_url.is_a?(URI) ? base_url : URI(base_url.to_s)
      end

      def normalize(input)
        raise ArgumentError, "Input should be an array." unless input.is_a?(Array)
        raise ArgumentError, "Input array is empty." if input.empty?

        Scraper.logger.info("Normalizing #{input.size} movies for #{date}.")
        input.map { |movie| normalize_movie(movie) }
      end

      private

      def normalize_movie(movie)
        normalized = {}
        movie.each { |key, value| normalized[key] = send("normalize_#{key}", value) }
        normalized
      end

      def normalize_poster(poster)
        normalize_poster_url(poster, base_url: base_url)
      end

      def normalize_title(title)
        raise Scraper::InvalidMovieError, "Movie has an empty title." if title.nil? || title.strip.empty?

        title.sub(VOSE_SUFFIX, "").strip
      end

      def normalize_language(language)
        normalize_language_from_map(language, LANGUAGE_MAP)
      end

      def normalize_showtimes(showtimes)
        return [] if showtimes.nil? || showtimes.empty?

        showtimes.map { |s| { date: Time.strptime("#{date} #{s.strip} +0000", "%Y-%m-%d %H:%M %z") } }
      end
    end
  end
end
