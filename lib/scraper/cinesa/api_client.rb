# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module Scraper
  module Cinesa
    # Query the Cinesa API.
    class ApiClient
      attr_reader :headers, :site_id

      API_URL = "https://vwc.cinesa.es/WSVistaWebClient/ocapi/v1/showtimes/by-business-date"

      def initialize(headers, site_id)
        @headers = headers
        @site_id = site_id
      end

      def data
        Scraper.logger.info("GET #{build_url}.")
        uri = URI(build_url)
        response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          http.get(uri.request_uri, headers)
        end
        Scraper.logger.info("Data obtained.")
        response.body
      end

      private

      def build_url # TODO: different dates
        "#{API_URL}/first?siteIds=#{site_id}"
      end
    end
  end
end
