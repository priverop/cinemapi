# frozen_string_literal: true

require "nokogiri"

module Scraper
  module Mk2
    class MovieParser
      attr_reader :document, :day_num

      CSS_SELECTORS = {
        movie_block: ".horarios",
        peli:        ".peli",
        poster:      "img.img-responsive",
        title:       "p.gibsonT a.negro",
        info:        "p.gibsonL:not(.reset-lh)",
        vose_label:  ".etiqueta-vose",
        showtimes:   ".horas.horas-cine a.btn"
      }.freeze

      def initialize(html, day_num)
        @document = Nokogiri::HTML(html)
        @day_num  = day_num
      end

      def parse
        container = document.at_css(".contenedor_cines.cines-#{day_num}")
        raise Scraper::MoviesNotFoundError, "Movies not found." if container.nil?

        blocks = container.css(CSS_SELECTORS[:movie_block])
        raise Scraper::MoviesNotFoundError, "Movies not found." if blocks.empty?

        Scraper.logger.info("Parsed #{blocks.size} movies from day #{day_num}.")
        blocks.map { |block| parse_movie(block) }
      end

      private

      def parse_movie(block)
        peli = block.at_css(CSS_SELECTORS[:peli])
        info = peli&.css(CSS_SELECTORS[:info]) || []
        {
          poster:    peli&.at_css(CSS_SELECTORS[:poster])&.[]("src"),
          title:     peli&.at_css(CSS_SELECTORS[:title])&.text,
          director:  info[0]&.text,
          duration:  info[1]&.text,
          language:  peli&.at_css(CSS_SELECTORS[:vose_label]) ? :vose : :dubbed,
          showtimes: parse_showtimes(block)
        }
      end

      def parse_showtimes(block)
        block.css(CSS_SELECTORS[:showtimes]).filter_map do |btn|
          btn.text.match(/\d{2}:\d{2}/)&.to_s
        end
      end
    end
  end
end
