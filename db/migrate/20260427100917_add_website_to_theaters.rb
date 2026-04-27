class AddWebsiteToTheaters < ActiveRecord::Migration[8.1]
  def change
    add_column :theaters, :website, :string
    add_column :theaters, :scraper_key, :integer, null: true
    add_column :theaters, :scraper_external_id, :integer, null: true
    add_column :theaters, :is_enabled, :boolean, null: false, default: true
  end
end
