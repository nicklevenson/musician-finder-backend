class FixTagColumnNames < ActiveRecord::Migration[6.1]
  def change
    rename_column :tags, :spotify_image_url, :image_url
    rename_column :tags, :spotify_link, :link
    rename_column :tags, :spotify_uri, :uri
  end
end
