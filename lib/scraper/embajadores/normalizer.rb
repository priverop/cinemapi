# frozen_string_literal: true

require "time"
require_relative "../normalizer_helpers"

module Scraper
  module Embajadores
    class Normalizer
      include Scraper::NormalizerHelpers

      # V.E. is ambiguous: original audio with no subtitles (:vo) unless the
      # title carries the "DOBLADA AL ESPAÑOL" suffix, which marks a dub.
      LANGUAGE_MAP = {
        /V\.O\.S\.E\./ => :vose,
        /V\.O\./       => :vo
      }.freeze

      VE_REGEX           = /V\.E\./
      DUBBED_TITLE_REGEX = /DOBLADA AL ESPA[NÑ]OL/i
      DURATION_REGEX     = /\d+/

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
          language:  normalize_language(movie[:language], movie[:title]),
          poster:    normalize_poster(movie[:poster]),
          showtimes: showtimes
        }
      rescue Scraper::UnknownLanguageError => e
        Scraper.logger.error("Language failure for '#{movie[:title]}': #{e.message}")
        raise
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

      def normalize_language(language, title)
        return ve_language(title) if language.to_s.match?(VE_REGEX)

        normalize_language_from_map(language, LANGUAGE_MAP)
      end

      def ve_language(title)
        title.to_s.match?(DUBBED_TITLE_REGEX) ? :dubbed : :vo
      end

      def normalize_poster(poster)
        normalize_poster_url(poster)
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
