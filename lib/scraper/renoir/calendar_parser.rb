# frozen_string_literal: true

require "nokogiri"

module Scraper
  module Renoir
    # Gets all the URL for the available days with the movie listings.
    class CalendarParser
      attr_reader :document

      CSS_SELECTORS = {
        dropdown: "select#elige-dia",
        day_option: "option[value^='/cine/']"
      }

      def initialize(html)
        @document = Nokogiri::HTML(html)
      end

      def urls
        dropdown = document.at_css(CSS_SELECTORS[:dropdown])

        raise Scraper::CalendarNotFoundError, "Calendar not found." if dropdown.nil?

        urls = dropdown.css(CSS_SELECTORS[:day_option]).map { |day| day["value"] }
        Scraper.logger.info("Found #{urls.count} day URLs.")
        urls
      end
    end
  end
end
