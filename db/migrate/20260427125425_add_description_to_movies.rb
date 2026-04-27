class AddDescriptionToMovies < ActiveRecord::Migration[8.1]
  def change
    add_column :movies, :description, :text
  end
end
