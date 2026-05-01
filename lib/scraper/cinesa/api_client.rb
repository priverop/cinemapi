# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module Scraper
  module Cinesa
    # Query the Cinesa API.
    class ApiClient
      attr_reader :headers, :site_id

      def initialize(headers, site_id)
        @headers = headers
        @site_id = site_id
      end

      def data(url)
        validate_url!(url)
        Scraper.logger.info("GET #{build_url(url)}.")
        uri = URI(build_url(url))
        response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          http.get(uri.request_uri, headers)
        end
        raise Scraper::HttpError, "HTTP #{response.code} fetching #{url}." unless response.is_a?(Net::HTTPSuccess)

        Scraper.logger.info("Data obtained.")
        response.body
      end

      private

      def build_url(url)
        "#{url}?siteIds=#{site_id}"
      end

      def validate_url!(url)
        raise Scraper::InvalidUrlError, "Invalid URI '#{url}'." unless Scraper.valid_http_url?(url)
      end
    end
  end
end
