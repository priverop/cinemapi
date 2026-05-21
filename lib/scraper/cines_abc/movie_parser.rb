# frozen_string_literal: true

require "nokogiri"

module Scraper
  module CinesAbc
    # Parses a Cines ABC single-movie ficha page.
    class MovieParser
      attr_reader :document

      CSS_SELECTORS = {
        title:       ".ficha-titulo div[id-ficha]",
        poster:      ".ficha-imagen img",
        description: ".ficha-sinopsis",
        info_field:  ".ficha-informacion-etiqueta",
        date_tabs:   "#tabs-sesiones ul li a"
      }.freeze

      DATE_REGEX = %r{\A\d{2}/\d{2}/\d{4}\z}
      TIME_REGEX = /\A\d{1,2}:\d{2}\z/

      def initialize(html)
        @document = Nokogiri::HTML(html)
      end

      def parse
        title = document.at_css(CSS_SELECTORS[:title])&.text&.strip
        raise Scraper::InvalidMovieError, "Movie title not found." if title.nil? || title.empty?

        fields = labelled_fields
        {
          title:       title,
          poster:      document.at_css(CSS_SELECTORS[:poster])&.[]("src"),
          description: description,
          duration:    fields["DURACIÓN"],
          genres:      genres(fields["GÉNERO"]),
          showtimes:   sessions
        }
      end

      private

      def description
        text = document.at_css(CSS_SELECTORS[:description])&.text&.strip
        return nil if text.nil? || text.empty?

        text
      end

      def labelled_fields
        fields = {}
        document.css(CSS_SELECTORS[:info_field]).each do |field|
          label = field.at_css("b")&.text.to_s.strip.chomp(":").strip
          value = field.at_css("span")&.text.to_s.strip
          fields[label] = value unless label.empty?
        end
        fields
      end

      def genres(value)
        return [] if value.nil? || value.strip.empty?

        value.split(/[,\/]/).map(&:strip).reject(&:empty?)
      end

      def sessions
        document.css(CSS_SELECTORS[:date_tabs]).flat_map do |tab|
          href = tab["href"].to_s
          date = tab.at_css(".fch-format")&.text.to_s.strip
          next [] unless date.match?(DATE_REGEX) && href.start_with?("#tabs-")

          panel_id = href.delete_prefix("#")
          panel = document.at_xpath("//*[@id=$id]", nil, id: panel_id)
          next [] if panel.nil?

          panel.css(".cont-ses").filter_map do |ses|
            hora_node = ses.at_css(".hora-ses")
            next nil if hora_node.nil?

            time = hora_node.children.find(&:text?)&.text.to_s.strip
            language = ses.at_css(".etiq-hora")&.text.to_s.strip
            next nil unless time.match?(TIME_REGEX)

            { date: date, time: time, language: language }
          end
        end
      end
    end
  end
end
