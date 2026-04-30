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
        json["filmScreeningDates"].map { |date| date["businessDate"]  }
      end
    end
  end
end
