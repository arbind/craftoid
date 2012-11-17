module GeoAliases
  # Be sure to have these geo fields available in classes that including the GeoAliases module:
  # field :location_hash
  # field :address, default: nil
  # field :coordinates, type: Array, default: []

  def Geocoder.clear_cache() Geocoder.cache.expire(:all) if Geocoder.cache.present? end

  # geocoding  aliases
  def ip_address() address end
  def ip_address=(val) self.address=ip_address end

  def latitude
    coordinates.last
  end
  alias_method :lat, :latitude

  def latitude=(lat)
    self.coordinates ||= [0,0]
    self.coordinates[1] = lat
  end
  alias_method :lat=, :latitude=

  def longitude
    coordinates.first
  end
  alias_method :lng, :longitude
  alias_method :long, :longitude

  def longitude=(lng)
    self.coordinates ||= [0,0]
    self.coordinates[0] = lng
  end
  alias_method :lng=, :longitude=
  alias_method :long=, :longitude=
  # /geocoding  aliases

  # geo point hash representation
  def geo_point
   { lat:lat, lng:lng }
  end
  def geo_point=(latlng_hash)
    lt   = latlng_hash[:latitude]   if latlng_hash[:latitude].present?
    lt ||= latlng_hash[:lat]        if latlng_hash[:lat].present?

    ln   = latlng_hash[:longitude]  if latlng_hash[:longitude].present?
    ln ||= latlng_hash[:long]       if latlng_hash[:long].present?
    ln ||= latlng_hash[:lng]        if latlng_hash[:lng].present?

    self.lat = lt
    self.lng = ln
    { lat:lat, lng:lng }
  end
  alias_method :geo_coordinate, :geo_point
  alias_method :geo_coordinate=, :geo_point=
  # /geo point hash representation

  def geocode_this_location!
    if self.lat.present? and (new? or changes[:coordinates].present?)
      reverse_geocode # update the address
    elsif address.present? and (new? or changes[:address].present?)
      geocode # update lat, lng
    elsif self.location_hash.present? and not self.lat.present? and (new? or changes[:location_hash].present?)
      l = []
      (l << location_hash[:address].to_s) if location_hash[:address].present?
      (l << location_hash[:city].to_s) if location_hash[:city].present?
      (l << location_hash[:state].to_s) if location_hash[:state].present?
      (l << location_hash[:zip].to_s) if location_hash[:zip].present?
      (l << location_hash[:country].to_s) if location_hash[:country].present?
      self.address = l.join(', ') if l.present?
      geocode # update lat, lng
    end
    return true
  end

end
