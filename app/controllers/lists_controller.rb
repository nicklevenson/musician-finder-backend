class ListsController < ApplicationController
  def get_instruments
    root = Rails.root.to_s
    @instruments = JSON.parse(File.read("#{root}/db/instruments.json"))
    render json: @instruments
  end 

  def get_genres
    root = Rails.root.to_s
    @genres = JSON.parse(File.read("#{root}/db/genres.json"))
    render json: @genres
  end

  def get_cities
    root = Rails.root.to_s
    @cities = JSON.parse(File.read("#{root}/db/cities.json"))
    render json: @cities
  end
end
