# frozen_string_literal: true

require_relative '../../../../lib/scraper/malda/post_finder'
require_relative '../../../../lib/scraper/client'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Malda::PostFinder do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures', 'malda') }
  let(:json) { File.read(File.join(fixtures_path, 'search_resurrection.json')) }
  let(:base_url) { URI("https://www.cinemamalda.com/cartelera-dia-dia/") }
  let(:finder) { described_class.new(base_url: base_url) }

  describe "#url" do
    it "queries the WordPress REST search endpoint" do
      expected = URI("https://www.cinemamalda.com/wp-json/wp/v2/posts?search=RESURRECTION&_fields=slug%2Ctitle&per_page=1")
      allow(Scraper::Client).to receive(:read).with(expected).and_return(json)
      finder.url("RESURRECTION")
      expect(Scraper::Client).to have_received(:read).with(expected)
    end

    it "returns the detail page URL built from the resolved slug" do
      allow(Scraper::Client).to receive(:read).and_return(json)
      expect(finder.url("RESURRECTION")).to eq(URI("https://www.cinemamalda.com/resurrection/"))
    end

    it "returns nil when the search yields no results" do
      allow(Scraper::Client).to receive(:read).and_return("[]")
      expect(finder.url("DOES NOT EXIST")).to be_nil
    end

    it "strips parentheses from the title before searching" do
      expected = URI("https://www.cinemamalda.com/wp-json/wp/v2/posts?search=UYARIY+ESCUCHAR&_fields=slug%2Ctitle&per_page=1")
      allow(Scraper::Client).to receive(:read).with(expected).and_return(json)
      finder.url("UYARIY (ESCUCHAR)")
      expect(Scraper::Client).to have_received(:read).with(expected)
    end
  end
end
