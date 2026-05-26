# frozen_string_literal: true

require "json"

module Scraper
  module VerdiBarcelona
    # Parses a single Verdi Barcelona movie JSON (the /api/get-event-by-imdbid
    # response). Each movie has one or more "events" (language versions), and
    # each event has a list of "performances" (the individual showtimes). The
    # poster is not part of this JSON; it comes from the listing (see ListParser)
    # and is injected by the Orchestrator after parsing.
    class MovieParser
      attr_reader :result

      def initialize(input)
        @result = JSON.parse(input)["result"]
      end

      def parse
        raise Scraper::InvalidMovieError, "Movie data not found." if result.nil?

        {
          title: title,
          directors: directors,
          duration: duration,
          genres: genres,
          description: description,
          showtimes: showtimes
        }
      end

      private

      def title
        result["locale_name"] || result["name"]
      end

      def directors
        Array(result["directors"]).filter_map { |director| director[1] }
      end

      def duration
        result["runtime"]
      end

      def genres
        Array(result["genres"]).filter_map { |genre| genre[1] }
      end

      def description
        result["plot"].presence || result["synopsis"]
      end

      def showtimes
        Array(result["events"]).flat_map do |event|
          Array(event["performances"]).map do |performance|
            { date: performance["time"], language: event["version"] }
          end
        end
      end
    end
  end
end
