# frozen_string_literal: true

module Scraper
  # Import clean data into the DataBase.
  class Importer
    attr_reader :theater

    def initialize(theater:)
      @theater = theater
    end

    def import(movies)
      Scraper.logger.info("Importing #{movies.count} movies.")
      movies.each { |movie| import_movie(movie) }
    end

    private

    def import_movie(movie)
      ActiveRecord::Base.transaction do
        record = Movie.find_or_initialize_by(title: movie[:title])
        if record.new_record?
          record.assign_attributes(
            description: movie[:description],
            duration: movie[:duration],
            directors: movie[:directors],
            genre: movie[:genres]&.first, # TODO: support multiple genres in Movie model.
            poster: movie[:poster]
          )
          record.save!
          Scraper.logger.info("Movie created: #{record.title} (id=#{record.id}).")
        else
          Scraper.logger.info("Movie exists: #{record.title} (id=#{record.id}).")
        end

        movie[:showtimes].each { |st| import_showtime(record, st, movie[:language]) }
      end
    rescue ActiveRecord::RecordInvalid => e
      Scraper.logger.error("Import failed for '#{movie[:title]}': #{e.message}.")
      raise
    end

    def import_showtime(movie_record, showtime, language)
      st = Showtime.find_or_initialize_by(theater: theater, movie: movie_record, showtime: showtime[:date])
      if st.new_record?
        st.language = language.present? ? language : showtime[:language]
        st.save!
        Scraper.logger.info("Showtime created: #{movie_record.title} @ #{showtime}.")
      else
        Scraper.logger.debug("Showtime exists: #{movie_record.title} @ #{showtime}.")
      end
    end
  end
end
