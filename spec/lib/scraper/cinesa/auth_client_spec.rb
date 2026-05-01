# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../lib/scraper'
require_relative '../../../../lib/scraper/cinesa/auth_client'

RSpec.describe Scraper::Cinesa::AuthClient do
  let(:theater_url) { "https://www.cinesa.es/cines/cine-pio-xii/" }
  let(:browser)     { double("Ferrum::Browser") }
  let(:page)        { double("Ferrum::Page") }
  let(:headers_dbl) { double("Ferrum::Browser::Headers") }

  let(:vista_params) do
    {
      "request" => {
        "url"     => "https://vwc.cinesa.es/WSVistaWebClient/ocapi/v1/film-screening-dates",
        "headers" => { "Authorization" => "Bearer jwt-token" }
      }
    }
  end

  before do
    allow(Ferrum::Browser).to receive(:new).and_return(browser)
    allow(browser).to receive(:headers).and_return(headers_dbl)
    allow(headers_dbl).to receive(:set)
    allow(browser).to receive(:page).and_return(page)
    allow(browser).to receive(:quit)
    allow(page).to receive(:command)
    allow(page).to receive(:go_to)
    allow(page).to receive(:url).and_return(theater_url)
  end

  describe ".fetch_headers" do
    context "when JWT is captured from a Vista network request" do
      before do
        allow(page).to receive(:on).with("Network.requestWillBeSent") do |_event, &block|
          block.call(vista_params)
        end
      end

      it "returns an Authorization header" do
        result = described_class.fetch_headers(theater_url)
        expect(result).to eq({ "Authorization" => "Bearer jwt-token" })
      end
    end

    context "when no JWT is captured within the timeout" do
      before do
        allow(page).to receive(:on)
        stub_const("Scraper::Cinesa::AuthClient::TIMEOUT", 0)
      end

      it "raises AuthRequiredError" do
        expect { described_class.fetch_headers(theater_url) }
          .to raise_error(Scraper::AuthRequiredError, /Could not capture JWT/)
      end
    end

    context "when page navigation times out but JWT was already captured" do
      before do
        allow(page).to receive(:on).with("Network.requestWillBeSent") do |_event, &block|
          block.call(vista_params)
        end
        allow(page).to receive(:go_to).and_raise(Ferrum::TimeoutError)
      end

      it "returns the captured Authorization header" do
        result = described_class.fetch_headers(theater_url)
        expect(result).to eq({ "Authorization" => "Bearer jwt-token" })
      end
    end
  end
end
