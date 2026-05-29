# frozen_string_literal: true

require "nokogiri"

module Scraper
  module AdmitOne
    # Parses the admit-one cartelera HTML (Verdi Madrid, Cinemes Girona).
    # The page contains all movies and all dates inline; each movie has a
    # set of desktop tab-panes, one per date, with rows of language + times.
    class MovieParser
      CSS_SELECTORS = {
        movie_container:  "article.article-cartelera",
        movie_title:      "div.col-md-8 > h2 > a",
        movie_poster:     "figure.cartelera-figure img.d-none.d-md-block",
        movie_description: "div.col-md-8 > p",
        movie_meta_rows:  "table tbody tr",
        showtime_pane:    "div.tabs-performances div.tab-content div.tab-pane",
        showtime_row:     "div.row.pelicula",
        showtime_label:   "span",
        showtime_link:    "a[href*='perfCode']"
      }.freeze

      SKIP_LABELS = %w[CONCIERTO BALLET].freeze

      attr_reader :document

      def initialize(html)
        @document = Nokogiri::HTML(html)
      end

      def parse
        movie_nodes = document.css(CSS_SELECTORS[:movie_container])
        raise Scraper::MoviesNotFoundError, "Movies not found." if movie_nodes.empty?

        movies = movie_nodes.filter_map { |node| parse_movie(node) }
        Scraper.logger.info("Parsed #{movies.size} movies from page.")
        movies
      end

      private

      def parse_movie(node)
        showtimes = parse_showtimes(node)
        return nil if showtimes.empty?
        return nil if showtimes.any? { |s| SKIP_LABELS.include?(s[:language].to_s.strip.upcase) }

        {
          title: node.at_css(CSS_SELECTORS[:movie_title])&.text,
          directors: meta_value(node, "DIRECTOR"),
          duration: meta_value(node, "DURACIÓN"),
          genres: meta_genres(node),
          poster: node.at_css(CSS_SELECTORS[:movie_poster])&.[]("src"),
          description: node.at_css(CSS_SELECTORS[:movie_description])&.text,
          showtimes: showtimes
        }
      end

      def parse_showtimes(node)
        node.css(CSS_SELECTORS[:showtime_pane]).flat_map do |pane|
          pane.css(CSS_SELECTORS[:showtime_row]).flat_map do |row|
            label = row.at_css(CSS_SELECTORS[:showtime_label])&.text
            row.css(CSS_SELECTORS[:showtime_link]).map do |link|
              { date: link["title"], language: label }
            end
          end
        end
      end

      def meta_row(node, label)
        node.css(CSS_SELECTORS[:movie_meta_rows]).find do |row|
          row.at_css("th")&.text.to_s.upcase.include?(label)
        end
      end

      def meta_value(node, label)
        meta_row(node, label)&.at_css("td")&.text
      end

      def meta_genres(node)
        row = meta_row(node, "GÉNERO")
        return [] if row.nil?

        row.css("td a").map { |a| a.text.strip }
      end
    end
  end
end
