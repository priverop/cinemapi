# frozen_string_literal: true

require "nokogiri"
require "date"

module Scraper
  module Malda
    # Parses the free-text weekly schedule in the cartelera-dia-dia page.
    #
    # The schedule lives in a `.sinopsi` block: an <h2> header with the week's
    # date range, then one <p> per day. Each <p> starts with a "<dayname> <dd>"
    # header followed by <br>-separated session lines like
    # "13:15h – FLORES PARA ANTONIO (VOE)".
    class CalendarParser
      attr_reader :document

      CSS_SELECTORS = {
        block: ".sinopsi",
        day: "p"
      }.freeze

      MONTHS = {
        "enero" => 1, "febrero" => 2, "marzo" => 3, "abril" => 4, "mayo" => 5, "junio" => 6,
        "julio" => 7, "agosto" => 8, "septiembre" => 9, "octubre" => 10, "noviembre" => 11, "diciembre" => 12
      }.freeze

      HEADER_REGEX = /DEL\s+(\d{1,2})\s+(?:DE\s+(\p{L}+)\s+)?AL\s+(\d{1,2})\s+DE\s+(\p{L}+)\s+DE\s+(\d{4})/iu
      SESSION_REGEX = /(\d{1,2}):(\d{2})h?\s*[–—-]\s*(.+)/u
      LANGUAGE_REGEX = /\((VOSE|VOE)\)/i

      def initialize(html)
        @document = Nokogiri::HTML(html)
      end

      def movies
        block = document.at_css(CSS_SELECTORS[:block])
        raise Scraper::CalendarNotFoundError, "Calendar not found." if block.nil?

        grouped = parse_weeks(block)
        result = grouped.map { |title, data| { title: title, language: data[:language], showtimes: data[:showtimes] } }
        Scraper.logger.info("Found #{result.count} movies in calendar.")
        result
      end

      private

      # The page lists one or more week sections, each an <h2> header ("CARTELERA
      # DEL .. AL .. DE <month> DE <year>") followed by its day paragraphs. We walk
      # the children in order so each paragraph is dated against its own header.
      def parse_weeks(block)
        grouped = {}
        week = nil
        header_seen = false

        block.children.each do |node|
          next unless node.element?

          header = node.text.match(HEADER_REGEX)
          if header
            week = build_week(header)
            header_seen = true
          elsif node.name == "p" && week
            parse_paragraph(node, week, grouped)
          end
        end

        raise Scraper::CalendarNotFoundError, "Calendar header not found." unless header_seen

        grouped
      end

      # Resolves the week's months and years. The header may omit the start month
      # (e.g. "DEL 29 AL 4 DE JUNIO"): when the start day is greater than the end
      # day the week wraps into the previous month.
      def build_week(match)
        start_day   = match[1].to_i
        end_day     = match[3].to_i
        end_month   = month_number(match[4])
        year        = match[5].to_i
        start_month = start_month_for(match[2], start_day, end_day, end_month)
        start_year  = start_month > end_month ? year - 1 : year

        { start_day: start_day, start_month: start_month, start_year: start_year, end_month: end_month, end_year: year }
      end

      def start_month_for(explicit_name, start_day, end_day, end_month)
        return month_number(explicit_name) if explicit_name

        start_day > end_day ? previous_month(end_month) : end_month
      end

      def parse_paragraph(paragraph, week, grouped)
        fragments = paragraph.inner_html.split(%r{<br\s*/?>}i)
        day = day_number(fragment_text(fragments.first))
        return if day.nil?

        fragments.drop(1).each { |fragment| parse_session(fragment_text(fragment), day, week, grouped) }
      end

      def parse_session(text, day, week, grouped)
        match = text.match(SESSION_REGEX)
        return if match.nil?

        rest = match[3].strip
        language_match = rest.match(LANGUAGE_REGEX)
        # Every real film is tagged (VOE) or (VOSE); untagged lines are hall
        # rentals, concerts or other non-film events, so we skip them.
        return if language_match.nil?

        title = rest[0...language_match.begin(0)].strip
        return if title.empty?

        date = date_for(day, week)
        time = Time.utc(date.year, date.month, date.day, match[1].to_i, match[2].to_i)
        entry = (grouped[title] ||= { language: language_match[1].upcase, showtimes: [] })
        entry[:showtimes] << time
      end

      def fragment_text(fragment)
        Nokogiri::HTML.fragment(fragment.to_s).text.gsub(" ", " ").strip
      end

      def day_number(text)
        without_price = text.sub(/\(.*\)/, "")
        match = without_price.match(/(\d{1,2})/)
        match&.captures&.first&.to_i
      end

      def date_for(day, week)
        if day >= week[:start_day]
          Date.new(week[:start_year], week[:start_month], day)
        else
          Date.new(week[:end_year], week[:end_month], day)
        end
      end

      def previous_month(month)
        month == 1 ? 12 : month - 1
      end

      def month_number(name)
        MONTHS[name.to_s.downcase] || raise(Scraper::CalendarNotFoundError, "Unknown month '#{name}'.")
      end
    end
  end
end
