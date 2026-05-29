# frozen_string_literal: true

require "nokogiri"

module Scraper
  module Golem
    # Extracts day URLs from the main Golem cartelera page.
    class CalendarParser
      attr_reader :document

      CSS_SELECTORS = {
        day_link: "td.tabNoDia a[href*='/golem/golem-madrid/']"
      }.freeze

      DATE_REGEX = %r{/golem/golem-madrid/(\d{4})(\d{2})(\d{2})\z}

      def initialize(html)
        @document = Nokogiri::HTML(html)
      end

      def days
        anchors = document.css(CSS_SELECTORS[:day_link])

        raise Scraper::CalendarNotFoundError, "Calendar not found." if anchors.empty?

        days = anchors.filter_map { |a| parse_anchor(a) }.uniq { |d| d[:url] }
        Scraper.logger.info("Found #{days.count} day URLs.")
        days
      end

      private

      def parse_anchor(anchor)
        url = anchor["href"]
        match = url&.match(DATE_REGEX)

        if match.nil?
          Scraper.logger.warn("Skipping calendar URL with invalid date: #{url.inspect}.")
          return nil
        end

        { url: url, date: "#{match[1]}-#{match[2]}-#{match[3]}" }
      end
    end
  end
end
