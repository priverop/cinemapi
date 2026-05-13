# frozen_string_literal: true

require "time"

module Scraper
  module Embajadores
    class Normalizer
      LANGUAGE_MAP = {
        /V\.O\.S\.E\./ => :vose,
        /V\.O\./       => :vo,
        /V\.E\./       => :dubbed
      }.freeze

      DURATION_REGEX = /\d+/

      attr_reader :date, :venue_slug

      def initialize(date, venue_slug)
        @date       = date
        @venue_slug = venue_slug
      end

      def normalize(input)
        raise ArgumentError, "Input should be an array." unless input.is_a?(Array)
        raise ArgumentError, "Input array is empty." if input.empty?

        Scraper.logger.info("Normalizing #{input.size} movies for #{date} (venue: #{venue_slug}).")
        input.filter_map { |movie| normalize_movie(movie) }
      end

      private

      def normalize_movie(movie)
        showtimes = normalize_showtimes(movie[:showtimes])
        return nil if showtimes.empty?

        {
          title:     normalize_title(movie[:title]),
          directors: normalize_director(movie[:director]),
          duration:  normalize_duration(movie[:duration]),
          language:  normalize_language(movie[:language]),
          poster:    normalize_poster(movie[:poster]),
          showtimes: showtimes
        }
      end

      def normalize_title(title)
        raise Scraper::InvalidMovieError, "Movie has an empty title." if title.nil? || title.strip.empty?

        title.gsub(/\(.*?\)/, "").strip.titleize
      end

      def normalize_director(director)
        return [] if director.nil? || director.strip.empty?

        [ director.sub(/\Ade\s+/i, "").strip ]
      end

      def normalize_duration(duration)
        return nil if duration.nil? || duration.strip.empty?

        duration[DURATION_REGEX]&.to_i
      end

      def normalize_language(language)
        raise Scraper::UnknownLanguageError, "Unknown language #{language.inspect}." if language.nil? || language.strip.empty?

        result = LANGUAGE_MAP.find { |regex, _| language.match?(regex) }&.last
        raise Scraper::UnknownLanguageError, "Unknown language '#{language}'." if result.nil?

        result
      end

      def normalize_poster(poster)
        return nil if poster.nil? || poster.strip.empty?
        return poster if Scraper.valid_http_url?(poster)

        Scraper.logger.warn("Could not normalize poster: #{poster.inspect}.")
        nil
      end

      def normalize_showtimes(showtimes)
        return [] if showtimes.nil? || showtimes.empty?

        showtimes
          .select { |s| venue_showtime?(s.dig(:url).to_s) }
          .map    { |s| { date: Time.strptime("#{date} #{s[:time]} +0000", "%Y-%m-%d %H:%M %z") } }
      end

      def venue_showtime?(url)
        if venue_slug == "cineembajadores"
          url.include?("cineembajadores") && !url.include?("cineembajadoresrio")
        else
          url.include?(venue_slug)
        end
      end
    end
  end
end
