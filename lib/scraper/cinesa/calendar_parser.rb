# frozen_string_literal: true

require "json"

module Scraper
  module Cinesa
    # Parses the future available dates.
    class CalendarParser
      attr_reader :json

      def initialize(input)
        @json = JSON.parse(input)
      end

      def parse
        dates = json["filmScreeningDates"]

        raise Scraper::CalendarNotFoundError, "Calendar not found." if dates.nil?

        Scraper.logger.info("Found #{dates.count} day dates.")
        dates.map { |date| date["businessDate"] }
      end
    end
  end
end
