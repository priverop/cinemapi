# frozen_string_literal: true

require_relative '../../../lib/scraper/client'
require_relative '../../../lib/scraper'

RSpec.describe Scraper::Client do
  describe ".read" do
    context "valid cinema URL" do
      it "returns plain HTML" do
        url = "https://www.google.com"
        expect(described_class.read(url)).to include("Google")
      end
    end

    context "empty url parameter" do
      it 'raises InvalidUrlError' do
        url = ''
        expect do
          described_class.read(url)
        end.to raise_error Scraper::InvalidUrlError, "Invalid url ''."
      end
    end

    context "not string url parameter" do
      it 'raises InvalidUrlError' do
        url = 123
        expect do
          described_class.read(url)
        end.to raise_error Scraper::InvalidUrlError, "Invalid url '123'."
      end
    end

    context "nil url parameter" do
      it 'raises InvalidUrlError' do
        url = nil
        expect do
          described_class.read(url)
        end.to raise_error Scraper::InvalidUrlError, "Invalid url ''."
      end
    end
  end
end
