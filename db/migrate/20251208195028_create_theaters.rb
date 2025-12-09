class CreateTheaters < ActiveRecord::Migration[8.1]
  def change
    create_table :theaters do |t|
      t.string :name
      t.string :location
      t.decimal :price
      t.decimal :discounted_price
      t.string :discounted_days

      t.timestamps
    end
  end
end
