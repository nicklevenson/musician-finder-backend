class AddDetailsToTags < ActiveRecord::Migration[6.1]
  def change
    add_column :tags, :tag_type, :string
    add_column :tags, :spotify_image_url, :string
    add_column :tags, :spotify_link, :string
    add_column :tags, :spotify_uri, :string
  end
end
