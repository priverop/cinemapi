class CreateShowtimes < ActiveRecord::Migration[8.1]
  def change
    create_table :showtimes do |t|
      t.references :movie, null: false, foreign_key: true
      t.references :theater, null: false, foreign_key: true
      t.datetime :showtime

      t.timestamps
    end

    add_index :showtimes, [ :movie_id, :theater_id, :showtime ],
              name: 'index_showtimes_on_movie_theater_datetime'
  end
end
