# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../lib/scraper'
require_relative '../../../../lib/scraper/cinesa/api_client'

RSpec.describe Scraper::Cinesa::ApiClient do
  let(:calendar_url) { "https://vwc.cinesa.es/WSVistaWebClient/ocapi/v1/film-screening-dates" }
  let(:headers) { { "Authorization" => "Bearer test-token" } }
  let(:client) { described_class.new(headers, "027") }

  describe "#data" do
    context "with a successful response", vcr: { cassette_name: "cinesa/api_client/data_200" } do
      it "returns the response body and appends siteIds to the URL" do
        result = client.data(calendar_url)
        expect(result).to include("filmScreeningDates")
      end
    end

    context "with an error response", vcr: { cassette_name: "cinesa/api_client/data_401" } do
      it "raises HttpError" do
        expect { client.data(calendar_url) }.to raise_error(Scraper::HttpError, /HTTP 401/)
      end
    end
  end
end
