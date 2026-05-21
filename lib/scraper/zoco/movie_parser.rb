# frozen_string_literal: true

require "nokogiri"

module Scraper
  module Zoco
    # Parses a Cines Zoco Majadahonda single-movie detail page.
    class MovieParser
      attr_reader :document

      CSS_SELECTORS = {
        title:       "h1",
        poster:      "div.et_pb_image_0_tb_body img, div.imagen-resultado img, img.wp-post-image",
        description: "div.et_pb_post_content p",
        language_h4: "h4",
        sessions:    "div.sesion"
      }.freeze

      LABEL_REGEX  = /\A\s*<strong>([^<]+)<\/strong>\s*\|\s*(.+?)\s*\z/m
      DATE_REGEX   = /\b(\d{2}-\d{2}-\d{4})\b/
      TIME_REGEX   = /\A\d{1,2}:\d{2}\z/

      def initialize(html)
        @document = Nokogiri::HTML(html)
      end

      def parse
        title = document.at_css(CSS_SELECTORS[:title])&.text&.strip
        raise Scraper::InvalidMovieError, "Movie title not found." if title.nil? || title.empty?

        fields = extract_labelled_fields
        {
          title:       title,
          poster:      poster,
          directors:   fields["Director/a"],
          duration:    fields["Duración"],
          description: description,
          language:    language,
          showtimes:   sessions
        }
      end

      private

      def poster
        img = document.at_css(CSS_SELECTORS[:poster])
        return nil if img.nil?

        img["data-src"] || img["src"]
      end

      def description
        node = document.at_css(CSS_SELECTORS[:description])
        node&.text&.strip
      end

      def language
        document.css("h5").each do |h5|
          next unless h5.children.any? { |c| c.text? && c.text.strip.casecmp("Idioma").zero? }

          value = h5.at_css("h4")
          return value.text.strip if value
        end
        nil
      end

      def extract_labelled_fields
        fields = {}
        document.css("strong").each do |strong|
          label  = strong.text.to_s.strip
          parent = strong.parent
          next if parent.nil?

          text = parent.inner_html.strip
          match = text.match(LABEL_REGEX)
          next if match.nil?

          fields[label] = strip_tags(match[2]).strip
        end
        fields
      end

      def sessions
        document.css(CSS_SELECTORS[:sessions]).flat_map do |block|
          date_text = block.at_css("strong")&.text.to_s
          match = date_text.match(DATE_REGEX)
          next [] if match.nil?

          date = match[1]
          block.css("a").filter_map do |a|
            time = a.text.strip
            next nil unless time.match?(TIME_REGEX)

            { date: date, time: time }
          end
        end
      end

      def strip_tags(html_fragment)
        Nokogiri::HTML.fragment(html_fragment).text
      end
    end
  end
end
