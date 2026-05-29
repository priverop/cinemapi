# frozen_string_literal: true

require "nokogiri"

module Scraper
  module VerdiBarcelona
    # Parses a Verdi Barcelona cartelera page. The page is an Alpine.js SPA:
    # each movie is an <article> that lazy-loads its data with a
    # loadMovieData('ttIMDBID','/slug') call. We extract the imdbid (used to
    # query the JSON API), the slug, and the poster shown in the listing.
    class ListParser
      CSS_SELECTORS = {
        movie_article: "article",
        movie_poster:  "picture img"
      }.freeze

      LOAD_MOVIE_REGEX = /loadMovieData\(\s*'(?<imdbid>tt\d+)'\s*,\s*'(?<slug>[^']*)'/

      attr_reader :document

      def initialize(html)
        @document = Nokogiri::HTML(html)
      end

      def movies
        entries = document.css(CSS_SELECTORS[:movie_article]).filter_map do |article|
          match = article["x-intersect.once"].to_s.match(LOAD_MOVIE_REGEX)
          next nil if match.nil?

          {
            imdbid: match[:imdbid],
            slug: match[:slug],
            poster: article.at_css(CSS_SELECTORS[:movie_poster])&.[]("src")
          }
        end.uniq { |entry| entry[:imdbid] }

        raise Scraper::MoviesNotFoundError, "Movies not found." if entries.empty?

        Scraper.logger.info("Found #{entries.count} movies in cartelera.")
        entries
      end
    end
  end
end
