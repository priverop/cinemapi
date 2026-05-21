# frozen_string_literal: true

require_relative '../../../../lib/scraper/zoco/list_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Zoco::ListParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures', 'zoco') }

  describe "#movies" do
    context "valid homepage" do
      let(:html) { File.read(File.join(fixtures_path, 'home.html')) }

      it "returns the list of unique movie URLs" do
        movies = described_class.new(html).movies
        expect(movies.size).to eq(15)
        expect(movies).to all(include(:url))
        expect(movies.map { |m| m[:url] }).to include("https://cineszocomajadahonda.org/calle-malaga/")
      end
    end

    context "empty html" do
      it "raises MoviesNotFoundError" do
        parser = described_class.new("")
        expect { parser.movies }.to raise_error(Scraper::MoviesNotFoundError, "Movies not found.")
      end
    end
  end
end
