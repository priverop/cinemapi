# frozen_string_literal: true

module Scraper
  # Import clean data into the DataBase.
  class Importer
    attr_reader :theater

    def initialize(theater:)
      @theater = theater
    end

    def import(movies)
      movies.each do |movie|
        import_movie(movie)
      end
    end

    private

    def import_movie(movie)
      ActiveRecord::Base.transaction do
        new_movie = Movie.find_or_create_by!(name: movie[:title]) do |m|
          m.duration = movie[:duration]
          m.genre = "scraper"
        end

        movie[:showtimes].each do |st|
          Showtime.find_or_create_by!(theater:, movie: new_movie, showtime: st)
        end
      end
    end
  end
end
