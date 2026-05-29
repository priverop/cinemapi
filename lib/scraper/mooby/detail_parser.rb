# frozen_string_literal: true

require "nokogiri"

module Scraper
  module Mooby
    # Parses a Mooby movie detail page (e.g. /the-mandalorian-and-grogu). The
    # window.shops feed has no duration/director/genre, so we read them here
    # from the metadata table (<tr><th>Label</th><td>Value</td></tr>) and the
    # synopsis block. Returns raw strings; the Normalizer cleans them.
    class DetailParser
      CSS_SELECTORS = {
        meta_rows: "table tbody tr",
        synopsis:  "div.synopsis",
        poster:    "img"
      }.freeze

      LABELS = {
        duration:  "DURADA",
        directors: "DIRECCIÓ",
        genres:    "GÈNERE"
      }.freeze

      attr_reader :document

      def initialize(html)
        @document = Nokogiri::HTML(html.to_s)
      end

      def parse
        {
          duration: meta_value(LABELS[:duration]),
          directors: meta_value(LABELS[:directors]),
          genres: meta_value(LABELS[:genres]),
          description: document.at_css(CSS_SELECTORS[:synopsis])&.text,
          poster: poster_url
        }
      end

      private

      def meta_value(label)
        row = document.css(CSS_SELECTORS[:meta_rows]).find do |tr|
          tr.at_css("th")&.text.to_s.strip.upcase == label
        end
        row&.at_css("td")&.text&.strip
      end

      def poster_url
        src = document.at_css(CSS_SELECTORS[:poster])&.[]("src")
        src&.match?(/tt\d+/) ? src : nil
      end
    end
  end
end
