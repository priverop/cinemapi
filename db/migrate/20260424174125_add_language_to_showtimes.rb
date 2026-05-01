class AddLanguageToShowtimes < ActiveRecord::Migration[8.1]
  def change
    add_column :showtimes, :language, :integer, null: false, default: 0
  end
end
