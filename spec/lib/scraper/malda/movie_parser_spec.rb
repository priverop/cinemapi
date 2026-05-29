# frozen_string_literal: true

require_relative '../../../../lib/scraper/malda/movie_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Malda::MovieParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures', 'malda') }
  let(:html) { File.read(File.join(fixtures_path, 'movie_resurrection.html')) }

  describe "#parse" do
    context "valid HTML" do
      subject(:parsed) { described_class.new(html).parse }

      it "extracts the canonical title without the language span" do
        expect(parsed[:title]).to eq("Resurrection")
      end

      it "extracts directors" do
        expect(parsed[:directors]).to eq("Bi Gan")
      end

      it "extracts the raw duration" do
        expect(parsed[:duration]).to match(/160/)
      end

      it "extracts the genre preceding the duration" do
        expect(parsed[:genres]).to eq([ "Drama", "distopía" ])
      end

      it "extracts the synopsis as description" do
        expect(parsed[:description]).to start_with("En un mundo donde la humanidad")
      end

      it "extracts the poster from og:image" do
        expect(parsed[:poster]).to eq("https://www.cinemamalda.com/wp-content/uploads/2026/04/resurrection-685227398-large.jpg")
      end
    end

    context "synopsis label and genres formatted differently" do
      let(:kb_html) { File.read(File.join(fixtures_path, 'movie_kill_bill.html')) }
      subject(:parsed) { described_class.new(kb_html).parse }

      it "reads the synopsis from the paragraph following a standalone label" do
        expect(parsed[:description]).to start_with("Uma Thurman interpreta a La Novia")
      end

      it "splits genres separated by a dash" do
        expect(parsed[:genres]).to eq([ "Acción", "Thriller" ])
      end
    end

    context "empty html" do
      it "raises InvalidMovieError" do
        expect { described_class.new("").parse }.to raise_error(Scraper::InvalidMovieError, "Movie title not found.")
      end
    end
  end
end
