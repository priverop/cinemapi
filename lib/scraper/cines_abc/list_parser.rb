# frozen_string_literal: true

require "nokogiri"

module Scraper
  module CinesAbc
    # Parses a Cines ABC cartelera page and returns the list of
    # movie ficha-page URLs currently in cartelera.
    class ListParser
      attr_reader :document

      CSS_SELECTORS = {
        movie_block: ".cartelera",
        movie_link:  "a[href*='pag=ficha']",
        movie_title: ".cartelera-titulo .ver-ficha"
      }.freeze

      EVENTO_REGEX = /[?&]evento=\d+/

      def initialize(html)
        @document = Nokogiri::HTML(html)
      end

      def movies
        movies = document.css(CSS_SELECTORS[:movie_block]).filter_map do |block|
          url = block.at_css(CSS_SELECTORS[:movie_link])&.[]("href")
          next nil if url.nil? || !url.match?(EVENTO_REGEX)

          title = block.at_css(CSS_SELECTORS[:movie_title])&.text.to_s.strip
          { url: url, title: title }
        end.uniq { |m| m[:url] }

        raise Scraper::MoviesNotFoundError, "Movies not found." if movies.empty?

        Scraper.logger.info("Found #{movies.count} movie URLs.")
        movies
      end
    end
  end
end
