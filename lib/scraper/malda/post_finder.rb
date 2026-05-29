# frozen_string_literal: true

require "json"
require "uri"
require_relative "../client"

module Scraper
  module Malda
    # Resolves a movie title to its detail page URL via the WordPress REST API.
    #
    # The free-text schedule only gives titles; the detail page (with metadata)
    # lives at a slug WordPress may shorten (e.g. "Prime Crime: A True Story" ->
    # /prime-crime/). The REST search endpoint resolves the title to that slug
    # reliably, and its first result is the right post.
    class PostFinder
      SEARCH_PATH = "/wp-json/wp/v2/posts"

      def initialize(base_url:)
        @base_url = base_url.is_a?(URI) ? base_url : URI(base_url)
      end

      def url(title)
        results = JSON.parse(Scraper::Client.read(search_url(title)))
        slug = results.first&.dig("slug")
        return nil if slug.nil?

        base_url.merge("/#{slug}/")
      end

      private

      attr_reader :base_url

      def search_url(title)
        query = URI.encode_www_form(search: sanitize(title), _fields: "slug,title", per_page: 1)
        base_url.merge("#{SEARCH_PATH}?#{query}")
      end

      # WordPress search returns no results when the term contains parentheses,
      # so strip them and collapse whitespace before querying.
      def sanitize(title)
        title.to_s.gsub(/[()]/, " ").squeeze(" ").strip
      end
    end
  end
end
