# frozen_string_literal: true

require "nokogiri"

module Scraper
  module Malda
    # Parses a single movie detail page.
    #
    # The metadata is a slash-delimited line in the first `.sinopsi` paragraph:
    # "«Title» / Country: Year / Dirección: ... / Intérpretes: ... / Genre / NNN min / Version / Rating."
    class MovieParser
      attr_reader :document

      CSS_SELECTORS = {
        title: "h1.entry-title",
        meta: ".sinopsi p",
        synopsis: ".sinopsi p",
        poster: 'meta[property="og:image"]'
      }.freeze

      DIRECTORS_REGEX = /\Adirecci[oó]n\s*:/i
      DURATION_REGEX = /\d+\s*min/i
      SYNOPSIS_REGEX = /\ASinopsis\s*:?\s*/i
      GENRE_SEPARATOR = /[,–—]/

      def initialize(html)
        @document = Nokogiri::HTML(html)
      end

      def parse
        title_node = document.at_css(CSS_SELECTORS[:title])
        raise Scraper::InvalidMovieError, "Movie title not found." if title_node.nil?

        segments = meta_segments

        {
          title: title_text(title_node),
          directors: extract_directors(segments),
          duration: segments.find { |s| s.match?(DURATION_REGEX) },
          genres: extract_genres(segments),
          description: extract_description,
          poster: document.at_css(CSS_SELECTORS[:poster])&.[]("content")
        }
      end

      private

      def title_text(node)
        node.xpath("./text()").map(&:text).join.strip
      end

      def meta_segments
        first = document.at_css(CSS_SELECTORS[:meta])
        return [] if first.nil?

        first.text.split("/").map(&:strip).reject(&:empty?)
      end

      def extract_directors(segments)
        segment = segments.find { |s| s.match?(DIRECTORS_REGEX) }
        segment&.split(":", 2)&.last&.strip
      end

      def extract_genres(segments)
        duration_index = segments.index { |s| s.match?(DURATION_REGEX) }
        return [] if duration_index.nil? || duration_index.zero?

        segments[duration_index - 1].split(GENRE_SEPARATOR).map(&:strip).reject(&:empty?)
      end

      # The synopsis label and text may share one paragraph (e.g. "Sinopsis: ...")
      # or sit in separate paragraphs ("Sinopsis :" then the text below).
      def extract_description
        paragraphs = document.css(CSS_SELECTORS[:synopsis])
        index = paragraphs.find_index { |p| p.text.strip.match?(SYNOPSIS_REGEX) }
        return nil if index.nil?

        inline = paragraphs[index].text.strip.sub(SYNOPSIS_REGEX, "").strip
        return inline unless inline.empty?

        paragraphs[index + 1]&.text&.strip
      end
    end
  end
end
