# frozen_string_literal: true

require "nokogiri"

module Scraper
  module Zoco
    # Parses the Cines Zoco Majadahonda homepage and returns the list of
    # movie detail-page URLs currently in cartelera.
    class ListParser
      attr_reader :document

      CSS_SELECTORS = {
        movie_link: "a.mc-title-link[href]"
      }.freeze

      def initialize(html)
        @document = Nokogiri::HTML(html)
      end

      def movies
        links = document.css(CSS_SELECTORS[:movie_link])
        raise Scraper::MoviesNotFoundError, "Movies not found." if links.empty?

        urls = links.map { |a| a["href"] }.compact.uniq
        Scraper.logger.info("Found #{urls.count} movie URLs.")
        urls.map { |url| { url: url } }
      end
    end
  end
end
