# frozen_string_literal: true

require "nokogiri"
require "date"

module Scraper
  module Embajadores
    class CalendarParser
      attr_reader :document, :today

      CSS_SELECTORS = {
        day_link: "a.cartelera-dia[href*='cartelera-del-dia']"
      }.freeze

      def initialize(html, today: Date.today)
        @document = Nokogiri::HTML(html)
        @today = today
      end

      def days
        links = document.css(CSS_SELECTORS[:day_link])
        raise Scraper::CalendarNotFoundError, "Calendar not found." if links.empty?

        Scraper.logger.info("Found #{links.count} day links.")
        links.filter_map { |link| parse_link(link) }
      end

      private

      def parse_link(link)
        url  = link["href"]
        date = parse_date(link.text.strip)
        return nil if date.nil?

        { url: url, date: date }
      end

      def parse_date(text)
        return today if text.start_with?("Hoy")

        match = text.match(/(\d{2})\/(\d{2})/)
        return nil unless match

        day   = match[1].to_i
        month = match[2].to_i
        year  = today.year
        year += 1 if month < today.month
        Date.new(year, month, day)
      end
    end
  end
end
