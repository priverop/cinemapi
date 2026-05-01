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

      def days
        dropdown = document.at_css(CSS_SELECTORS[:dropdown])

        raise Scraper::CalendarNotFoundError, "Calendar not found." if dropdown.nil?

        days = dropdown.css(CSS_SELECTORS[:day_option]).filter_map { |option| parse_option(option) }
        Scraper.logger.info("Found #{days.count} day URLs.")
        days
      end

      private

      def parse_option(option)
        url = option["value"]
        date = extract_date(url)

        if date.nil? || date.strip.empty?
          Scraper.logger.warn("Skipping calendar URL with no fecha param: #{url.inspect}.")
          return nil
        end

        { url: url, date: date }
      end

      def extract_date(url)
        URI.decode_www_form(URI.parse(url).query.to_s).to_h["fecha"]
      end
    end
  end
end
