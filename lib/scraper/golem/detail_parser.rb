# frozen_string_literal: true

require "nokogiri"

module Scraper
  module Golem
    # Parses a Golem movie detail page (e.g. /golem/pelicula/Resurrection).
    # The day page omits the duration, so we read it here from the "Ficha
    # Técnica" table, where each row is two adjacent <td class="txtLectura">
    # cells: the first holds the label, the second the value.
    class DetailParser
      LABEL_CELLS = "td.txtLectura"
      DURATION_LABEL = /\Aduraci[oó]n:?\z/i

      attr_reader :document

      def initialize(html)
        @document = Nokogiri::HTML(html.to_s)
      end

      def parse
        { duration: value_for(DURATION_LABEL) }
      end

      private

      def value_for(label_regex)
        label_cell = document.css(LABEL_CELLS).find do |td|
          td.text.to_s.strip.match?(label_regex)
        end
        label_cell&.xpath("following-sibling::td[1]")&.text&.strip
      end
    end
  end
end
