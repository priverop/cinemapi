# frozen_string_literal: true

require_relative '../../../lib/scraper/client'
require_relative '../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Client do
  describe ".read" do
    context "valid cinema URL" do
      it "returns plain HTML" do
        VCR.use_cassette("scraper/client/google") do
          url = URI("https://www.google.com")
          expect(described_class.read(url)).to include("Google")
        end
      end
    end

    context "string url parameter" do
      it 'raises InvalidUrlError' do
        url = 'https://www.google.com'
        expect do
          described_class.read(url)
        end.to raise_error Scraper::InvalidUrlError, "Invalid URI 'https://www.google.com'."
      end
    end

    context "integer url parameter" do
      it 'raises InvalidUrlError' do
        url = 123
        expect do
          described_class.read(url)
        end.to raise_error Scraper::InvalidUrlError, "Invalid URI '123'."
      end
    end

    context "nil url parameter" do
      it 'raises InvalidUrlError' do
        url = nil
        expect do
          described_class.read(url)
        end.to raise_error Scraper::InvalidUrlError, "Invalid URI ''."
      end
    end

    context "non-2xx response" do
      it 'raises HttpError' do
        url = URI("https://www.example.com/not-found")
        allow(Net::HTTP).to receive(:get_response).and_return(Net::HTTPNotFound.new("1.1", "404", "Not Found"))
        expect do
          described_class.read(url)
        end.to raise_error Scraper::HttpError, "HTTP 404 fetching #{url}."
      end
    end
  end
end
