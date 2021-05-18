class AddLinksToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :soundcloud_link, :string
    add_column :users, :bandcamp_link, :string
    add_column :users, :youtube_link, :string
    add_column :users, :spotify_link, :string
    add_column :users, :apple_music_link, :string
    add_column :users, :instagram_link, :string
  end
end
