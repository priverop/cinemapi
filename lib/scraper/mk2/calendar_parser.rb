# frozen_string_literal: true

require "nokogiri"
require "date"

module Scraper
  module Mk2
    class CalendarParser
      attr_reader :document, :today

      CSS_SELECTORS = {
        day_tab: "div.rotulo_dia.cambiar-dia"
      }.freeze

      def initialize(html, today: Date.today)
        @document = Nokogiri::HTML(html)
        @today = today
      end

      def days
        tabs = document.css(CSS_SELECTORS[:day_tab])
        raise Scraper::CalendarNotFoundError, "Calendar not found." if tabs.empty?

        Scraper.logger.info("Found #{tabs.count} day tabs.")
        tabs.filter_map { |tab| parse_tab(tab) }
      end

      private

      def parse_tab(tab)
        num = tab["data-num"]&.to_i
        date = parse_date(tab.text.strip)
        return nil if date.nil?

        { num: num, date: date }
      end

      def parse_date(label)
        case label
        when "Hoy"    then today
        when "Mañana" then today + 1
        else
          match = label.match(/(\d{2})\/(\d{2})/)
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
end
