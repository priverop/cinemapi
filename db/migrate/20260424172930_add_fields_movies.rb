class AddFieldsMovies < ActiveRecord::Migration[8.1]
  def change
    rename_column :movies, :name, :title
    add_column :movies, :directors, :string
    add_column :movies, :poster, :string
    add_column :movies, :data_source, :integer, null: false, default: 0
    add_column :movies, :is_enabled, :boolean, null: false, default: true
  end
end
