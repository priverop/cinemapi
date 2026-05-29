class CreateScrapeFailures < ActiveRecord::Migration[8.1]
  def change
    create_table :scrape_failures do |t|
      t.references :scrape_run, null: false, foreign_key: true
      t.string :context
      t.text :error_message, null: false

      t.datetime :created_at, null: false
    end
  end
end
