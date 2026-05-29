# frozen_string_literal: true

require_relative '../../../../lib/scraper/verdi_barcelona/list_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::VerdiBarcelona::ListParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures', 'verdi_barcelona') }

  describe "#movies" do
    context "valid cartelera page" do
      let(:html) { File.read(File.join(fixtures_path, 'cartelera.html')) }

      it "returns one entry per movie with imdbid, slug and poster" do
        movies = described_class.new(html).movies
        expect(movies).not_to be_empty
        expect(movies).to all(include(:imdbid, :slug, :poster))
      end

      it "extracts the imdbid and slug from the loadMovieData call" do
        movies = described_class.new(html).movies
        expect(movies).to include(a_hash_including(imdbid: "tt21825416", slug: "/el-caso-hubener"))
      end

      it "extracts the poster url from the article image" do
        entry = described_class.new(html).movies.find { |m| m[:imdbid] == "tt21825416" }
        expect(entry[:poster]).to eq("https://www.bizcochito.es/img/tt21825416-ca-pos.webp")
      end

      it "deduplicates by imdbid" do
        imdbids = described_class.new(html).movies.map { |m| m[:imdbid] }
        expect(imdbids).to eq(imdbids.uniq)
      end
    end

    context "empty html" do
      it "raises MoviesNotFoundError" do
        expect { described_class.new("").movies }.to raise_error(Scraper::MoviesNotFoundError, "Movies not found.")
      end
    end
  end
end
