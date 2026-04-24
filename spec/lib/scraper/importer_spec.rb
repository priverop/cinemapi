# frozen_string_literal: true

require_relative '../../../lib/scraper/importer'
require_relative '../../../lib/scraper'
require 'rails_helper'

RSpec.describe Scraper::Importer do
  describe ".import" do
    context "when given theater exists" do
      let(:input) do
        [ {
          poster: nil,
          title: "PRIME CRIME: A TRUE STORY",
          directors: [ "Víctor García León" ],
          language: :vo,
          duration: 101,
          showtimes: [ Time.new(2026, 4, 23, 15, 50) ]
        },
        {
          poster: "https://subdomain.domain.com/imagenes/hash.jpg",
          title: "EL CRISTAL OSCURO [WILDER CINEMA]",
          directors: [ "Lluís Galter", "Eduardo Casanova", "Màrius Sánchez" ],
          language: :vose,
          duration: 123,
          showtimes: [ Time.new(2026, 4, 23, 16, 00), Time.new(2026, 4, 23, 18, 00), Time.new(2026, 4, 23, 22, 45) ]
        } ]
      end

      let!(:theater) { create(:theater) }

      it "creates the exact number of new movies" do
        importer = described_class.new(theater_id: theater.id)
        importer.import(input)

        expect(Movie.count).to eq(2)
      end
    end
  end
end
