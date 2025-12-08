class CreateMovies < ActiveRecord::Migration[8.1]
  def change
    create_table :movies do |t|
      t.string :name
      t.time :duration
      t.string :genre

      t.timestamps
    end
  end
end
