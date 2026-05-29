# frozen_string_literal: true

require_relative '../../../../lib/scraper/zumzeig/movie_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Zumzeig::MovieParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures', 'zumzeig') }
  let(:html) { File.read(File.join(fixtures_path, 'movie_la_chica_del_coro.html')) }

  describe "#parse" do
    context "valid HTML" do
      it "extracts title" do
        expect(described_class.new(html).parse[:title]).to eq("La chica del coro")
      end

      it "extracts directors string" do
        expect(described_class.new(html).parse[:directors]).to match(/Urška Djukić/)
      end

      it "extracts duration raw" do
        expect(described_class.new(html).parse[:duration]).to match(/89/)
      end

      it "extracts language raw" do
        expect(described_class.new(html).parse[:language]).to match(/VOSE/)
      end

      it "extracts description" do
        expect(described_class.new(html).parse[:description]).not_to be_empty
      end

      it "extracts poster URL" do
        expect(described_class.new(html).parse[:poster]).to match(%r{/site/assets/files/.+\.jpg})
      end

      it "extracts genres from body class" do
        expect(described_class.new(html).parse[:genres]).to include("estrenes")
      end
    end

    context "empty html" do
      it "raises InvalidMovieError" do
        expect { described_class.new("").parse }.to raise_error(Scraper::InvalidMovieError, "Movie title not found.")
      end
    end

    context "page without ficha técnica (event or theater)" do
      let(:html) do
        <<~HTML
          <html><body>
            <h1 class="filmtitle">Sobre la sesión solo</h1>
            <h4>Sobre la sesión</h4>
            <h4>El programa</h4>
          </body></html>
        HTML
      end

      it "returns nil so the orchestrator can skip it" do
        expect(described_class.new(html).parse).to be_nil
      end
    end
  end
end
