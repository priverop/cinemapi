# frozen_string_literal: true

require_relative '../../../lib/scraper/client'
require_relative '../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Client do
  describe ".read" do
    context "valid cinema URL" do
      it "returns plain HTML" do
        url = URI("https://www.google.com")
        expect(described_class.read(url)).to include("Google")
      end
    end

    context "string url parameter" do
      it 'raises InvalidUrlError' do
        url = 'https://www.google.com'
        expect do
          described_class.read(url)
        end.to raise_error Scraper::InvalidUrlError, "Invalid url 'https://www.google.com'."
      end
    end

    context "integer url parameter" do
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
