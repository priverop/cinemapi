# frozen_string_literal: true

require "time"
require "uri"
require_relative "../normalizer_helpers"

module Scraper
  module Ocine
    class Normalizer
      include Scraper::NormalizerHelpers

      LANGUAGE_MAP = {
        "dubbed" => :dubbed,
        "vose"   => :vose,
        "vo"     => :vo
      }.freeze

      VOSE_SUFFIX        = /\s*\(VOSE\)\s*/i
      POSTER_PATH_FORMAT = "/images/pelicules/%<id>s.jpg"

      attr_reader :base_url

      def initialize(base_url:)
        @base_url = base_url.is_a?(URI) ? base_url : URI(base_url.to_s)
      end

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
          directors:   [],
          duration:    normalize_duration(movie[:duration]),
          genres:      normalize_genres(movie[:genre]),
          description: normalize_description(movie[:description]),
          poster:      build_poster_url(movie[:movie_id]),
          language:    normalize_language(movie[:language]),
          showtimes:   normalize_showtimes(movie[:showtimes])
        }
      end

      def normalize_title(title)
        raise Scraper::InvalidMovieError, "Movie has an empty title." if title.nil? || title.strip.empty?

        title.gsub(VOSE_SUFFIX, " ").strip.squeeze(" ")
      end

      def normalize_duration(duration)
        return nil if duration.nil? || duration.to_s.strip.empty?

        duration.to_s[/\d+/]&.to_i
      end

      def normalize_genres(genre)
        return [] if genre.nil? || genre.to_s.strip.empty?

        [ genre.to_s.strip ]
      end

      def normalize_description(description)
        return nil if description.nil?

        cleaned = description.strip.squeeze(" ")
        cleaned.empty? ? nil : cleaned
      end

      def normalize_language(language)
        normalize_language_from_map(language.to_s, LANGUAGE_MAP)
      end

      def build_poster_url(movie_id)
        return nil if movie_id.nil?

        tickets_host = base_url.host.to_s.sub(/\A(?:www\.)?/, "tickets.")
        URI::HTTPS.build(host: tickets_host, path: format(POSTER_PATH_FORMAT, id: movie_id)).to_s
      end

      def normalize_showtimes(showtimes)
        return [] if showtimes.nil? || showtimes.empty?

        showtimes.filter_map do |st|
          date = st[:date].to_s
          time = st[:time].to_s
          next nil if date.empty? || time.empty?

          { date: Time.strptime("#{date} #{time} +0000", "%Y-%m-%d %H:%M:%S %z") }
        end
      end
    end
  end
end
