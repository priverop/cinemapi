# frozen_string_literal: true

require_relative '../../../../lib/scraper/cines_abc/list_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::CinesAbc::ListParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures', 'cines_abc') }

  describe "#movies" do
    context "valid cartelera page" do
      let(:html) { File.read(File.join(fixtures_path, 'el_saler_cartelera.html')) }

      it "returns the list of unique ficha URLs with titles" do
        movies = described_class.new(html).movies
        expect(movies).not_to be_empty
        expect(movies).to all(include(:url, :title))
        expect(movies.map { |m| m[:url] }).to all(include("pag=ficha"))
        expect(movies.map { |m| m[:title] }).to include("EL AMIGO INESPERADO")
      end

      it "deduplicates URLs" do
        movies = described_class.new(html).movies
        urls = movies.map { |m| m[:url] }
        expect(urls).to eq(urls.uniq)
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
