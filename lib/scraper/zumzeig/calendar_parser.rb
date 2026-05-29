# frozen_string_literal: true

require "nokogiri"
require "date"

module Scraper
  module Zumzeig
    # Parses the home calendar HTML and returns one entry per movie with its showtimes.
    class CalendarParser
      attr_reader :document

      CSS_SELECTORS = {
        calendar: ".calendarlist",
        day_block: ".day",
        month_header: "h5.monthname",
        day_num: "th.dianum",
        sessio: "tr.sessio",
        hora: "td.hora",
        film_link: "td.filmtitlecal a"
      }.freeze

      MONTHS = {
        "enero" => 1, "febrero" => 2, "marzo" => 3, "abril" => 4, "mayo" => 5, "junio" => 6,
        "julio" => 7, "agosto" => 8, "septiembre" => 9, "octubre" => 10, "noviembre" => 11, "diciembre" => 12,
        "gener" => 1, "febrer" => 2, "març" => 3, "maig" => 5, "juny" => 6,
        "juliol" => 7, "agost" => 8, "setembre" => 9, "novembre" => 11, "desembre" => 12
      }.freeze

      def initialize(html, today: Date.today)
        @document = Nokogiri::HTML(html)
        @today = today
      end

      def movies
        calendar = document.at_css(CSS_SELECTORS[:calendar])
        raise Scraper::CalendarNotFoundError, "Calendar not found." if calendar.nil?

        grouped = {}
        current_month = nil

        calendar.children.each do |node|
          next unless node.element?

          if node.matches?(CSS_SELECTORS[:month_header])
            current_month = month_number(node.text.strip)
          elsif node.matches?(CSS_SELECTORS[:day_block])
            parse_day(node, current_month, grouped)
          end
        end

        result = grouped.map { |url, showtimes| { url: url, showtimes: showtimes } }
        Scraper.logger.info("Found #{result.count} movies in calendar.")
        result
      end

      private

      attr_reader :today

      def parse_day(day_node, month, grouped)
        raise Scraper::CalendarNotFoundError, "Day block without month header." if month.nil?

        day_num = day_node.at_css(CSS_SELECTORS[:day_num])&.text&.strip&.to_i
        return if day_num.nil? || day_num.zero?

        date = build_date(month, day_num)

        day_node.css(CSS_SELECTORS[:sessio]).each do |sessio|
          link = sessio.at_css(CSS_SELECTORS[:film_link])
          hora = sessio.at_css(CSS_SELECTORS[:hora])
          next if link.nil? || hora.nil?

          url = link["href"]
          time = parse_time(date, hora.text)
          next if time.nil?

          grouped[url] ||= []
          grouped[url] << time
        end
      end

      def month_number(name)
        MONTHS[name.downcase] || raise(Scraper::CalendarNotFoundError, "Unknown month '#{name}'.")
      end

      def build_date(month, day)
        year = today.year
        year += 1 if month < today.month
        Date.new(year, month, day)
      end

      def parse_time(date, raw)
        match = raw.match(/(\d{1,2}):(\d{2})/)
        return nil if match.nil?

        Time.utc(date.year, date.month, date.day, match[1].to_i, match[2].to_i)
      end
    end
  end
end
