# frozen_string_literal: true

require "json"
require "nokogiri"

module Scraper
  module Mooby
    # Parses the Mooby Cinemas /cartelera page (Grup Balañà). The page ships a
    # `window.shops = {...}` JSON blob with every cinema, movie and showtime
    # inline, plus a static grid of <a href="/slug"><img src=".../ttID-..."> tiles
    # that links each movie to its detail page. We extract the blob, pick the
    # shop matching the theater's code (e.g. "BAL-BALMES") and return its movies,
    # each tagged with the slug needed to fetch richer metadata later.
    class MovieParser
      SHOPS_REGEX  = /window\.shops\s*=\s*(\{.*?\});/m
      IMDBID_REGEX = /tt\d+/
      SKIP_KEYWORD = "Eventos"

      attr_reader :shop_code, :document

      def initialize(html, shop_code)
        @html      = html.to_s
        @shop_code = shop_code
        @document  = Nokogiri::HTML(@html)
      end

      def parse
        shop     = find_shop
        slug_map = build_slug_map
        movies   = Array(shop.dig("events")).filter_map { |event| parse_event(event, slug_map) }
        raise Scraper::MoviesNotFoundError, "Movies not found." if movies.empty?

        Scraper.logger.info("Parsed #{movies.size} movies for shop #{shop_code}.")
        movies
      end

      private

      def shops
        match = @html.match(SHOPS_REGEX)
        raise Scraper::MoviesNotFoundError, "window.shops not found." if match.nil?

        JSON.parse(match[1])
      end

      def find_shop
        shop = shops.values.find { |s| s.dig("code") == shop_code }
        raise Scraper::MoviesNotFoundError, "Shop '#{shop_code}' not found." if shop.nil?

        shop
      end

      # Maps imdbid => { slug:, poster: } from the static movie-tile anchors.
      def build_slug_map
        document.css("a").each_with_object({}) do |anchor, map|
          img = anchor.at_css("img")
          src = img&.[]("src").to_s
          imdbid = src[IMDBID_REGEX]
          next if imdbid.nil? || anchor["href"].to_s.empty?

          map[imdbid] ||= { slug: anchor["href"], poster: src }
        end
      end

      def parse_event(event, slug_map)
        return nil if event.dig("keywords").to_s.include?(SKIP_KEYWORD)

        showtimes = parse_showtimes(event)
        return nil if showtimes.empty?

        imdbid = event.dig("imdbid")
        info   = slug_map[imdbid] || {}
        {
          title: event.dig("name"),
          imdbid: imdbid,
          slug: info[:slug] || "/#{slugify(event.dig('name'))}",
          poster: info[:poster],
          showtimes: showtimes
        }
      end

      def parse_showtimes(event)
        language = event_language(event)
        Array(event.dig("performances")).map do |perf|
          { date: perf.dig("time"), language: language }
        end
      end

      # The version field is the language label; when blank we infer it from the
      # subtitles: a subtitled showtime is VOSE, otherwise it is the original (ESP).
      def event_language(event)
        version = event.dig("version").to_s.strip
        return version unless version.empty?

        event.dig("subtitles_lang").to_s.strip.empty? ? "ESP" : "VOSE"
      end

      # Fallback slug for movies absent from the tile grid: ASCII-folded, dashed.
      def slugify(name)
        name.to_s.downcase.unicode_normalize(:nfkd).gsub(/[^\x00-\x7F]/, "")
            .gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-\z/, "")
      end
    end
  end
end
