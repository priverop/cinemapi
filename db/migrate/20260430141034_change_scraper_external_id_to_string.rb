class ChangeScraperExternalIdToString < ActiveRecord::Migration[8.1]
  def change
    change_column :theaters, :scraper_external_id, :string
  end
end
