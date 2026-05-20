# frozen_string_literal: true

require "nokogiri"

module Scraper
  module Zumzeig
    # Parses a single movie detail page and returns its attributes.
    class MovieParser
      attr_reader :document

      CSS_SELECTORS = {
        title: "h1.filmtitle",
        director_block: "h1.filmtitle + .autor",
        summary: ".b.summary .rowcontent",
        poster: ".cycle-slideshow img",
        body: "body",
        fitxa_title: "h4",
        fitxa_block: "h4 + .rowcontent, h4 ~ .rowcontent"
      }.freeze

      LABELS = {
        directors: /direcci[oó]n/i,
        duration: /duraci[oó]n|durada/i,
        language: /versi[oó]n/i
      }.freeze

      GENRE_REGEX = /tipo_([a-z]+)/

      def initialize(html)
        @document = Nokogiri::HTML(html)
      end

      def parse
        title_node = document.at_css(CSS_SELECTORS[:title])
        raise Scraper::InvalidMovieError, "Movie title not found." if title_node.nil?

        fields = extract_fitxa_fields

        {
          title: title_node.text.strip,
          directors: fields[:directors] || document.at_css(CSS_SELECTORS[:director_block])&.text&.strip,
          duration: fields[:duration],
          language: fields[:language],
          description: document.at_css(CSS_SELECTORS[:summary])&.text&.strip,
          poster: document.at_css(CSS_SELECTORS[:poster])&.[]("src"),
          genres: extract_genres
        }
      end

      private

      def extract_fitxa_fields
        fields = {}
        document.css("h4").each do |h4|
          next unless h4.text.strip.match?(/ficha t[eé]cnica|fitxa t[eè]cnica/i)

          block = h4.parent&.parent&.at_css(".rowcontent")
          next if block.nil?

          block.css("p").each do |p|
            text = p.text.strip
            label_match = text.match(/\A([^:]+):\s*(.+)\z/m)
            next if label_match.nil?

            label, value = label_match[1], label_match[2]
            LABELS.each do |key, regex|
              fields[key] = value.strip if label.match?(regex)
            end
          end
        end
        fields
      end

      def extract_genres
        body_class = document.at_css(CSS_SELECTORS[:body])&.[]("class").to_s
        body_class.scan(GENRE_REGEX).flatten.reject(&:empty?)
      end
    end
  end
end
