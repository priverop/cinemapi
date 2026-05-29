class CreateScrapeRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :scrape_runs do |t|
      t.references :theater, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.integer :items_ok, null: false, default: 0
      t.integer :items_failed, null: false, default: 0

      t.timestamps
    end
  end
end
