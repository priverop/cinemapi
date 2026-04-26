# frozen_string_literal: true

require_relative '../../../lib/scraper/importer'
require_relative '../../../lib/scraper'
require 'rails_helper'

RSpec.describe Scraper::Importer do
  describe ".import" do
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
    let(:importer) { described_class.new(theater: theater) }

    context "when given theater exists and has no movies" do
      it "creates the exact number of new movies" do
        expect{ importer.import(input) }.to change { Movie.count }.from(0).to(2)
      end

      it "creates movies with the right title" do
        importer.import(input)

        expect(Movie.where(title: input.first[:title])).to exist
        expect(Movie.where(title: input.last[:title])).to exist
      end

      it "creates movies with the right attributes" do
        importer.import(input)

        expect(Movie.find_by(title: input.first[:title])).to have_attributes(duration: 101)
        expect(Movie.find_by(title: input.last[:title])).to have_attributes(duration: 123)
      end

      it "creates the showtimes for the movies" do
        importer.import(input)

        movie = Movie.find_by(title: input.first[:title])

        expect(movie.showtimes.pluck(:showtime)).to match_array(input.first[:showtimes])

        movie = Movie.find_by(title: input.last[:title])
        expect(movie.showtimes.pluck(:showtime)).to match_array(input.last[:showtimes])
      end
    end

    context "when the movies and showtimes were already created" do
      before do
        importer.import(input)
      end

      it "doesnt create duplicates" do
        expect { importer.import(input) }.not_to change { Movie.count }
        expect { importer.import(input) }.not_to change { Showtime.count }
      end
    end

    context "when the movies were already created but different showtimes" do
      let(:movies_no_showtimes) do
        [ {
          poster: nil,
          title: "PRIME CRIME: A TRUE STORY",
          directors: [ "Víctor García León" ],
          language: :vo,
          duration: 101,
          showtimes: [ Time.new(2026, 4, 20, 15, 50) ]
        },
        {
          poster: "https://subdomain.domain.com/imagenes/hash.jpg",
          title: "EL CRISTAL OSCURO [WILDER CINEMA]",
          directors: [ "Lluís Galter", "Eduardo Casanova", "Màrius Sánchez" ],
          language: :vose,
          duration: 123,
          showtimes: [ Time.new(2026, 4, 20, 16, 00), Time.new(2026, 4, 20, 18, 00), Time.new(2026, 4, 20, 22, 45) ]
        } ]
      end
      before do
        importer.import(movies_no_showtimes)
      end

      it "doesnt create duplicated movies" do
        expect { importer.import(input) }.not_to change { Movie.count }
      end

      it "creates new showtimes" do
        expect { importer.import(input) }.to change { Showtime.count }.from(4).to(8)
      end
    end
  end
end
