class Geocoding

  def self.get_distance_between(lat1, lng1, lat2, lng2)
    earth_radius = 3958

    dLat = degrees_to_radius(lat2 - lat1)
    dLng = degrees_to_radius(lng2 - lng1)

    a = Math.sin(dLat/2) * Math.sin(dLat/2) +
        Math.cos(degrees_to_radius(lat1)) * Math.cos(degrees_to_radius(lat2)) *
        Math.sin(dLng/2) * Math.sin(dLng/2)

    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))

    distance = earth_radius * c

    distance
  end

  def self.degrees_to_radius(deg)
    deg * (Math::PI / 180)
  end

end