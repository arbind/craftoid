describe :GeoAliases do

  ###
  # Declare a class to host the mixin
  ###
  class GeoAliasesHost
    include Mongoid::Document
    include Mongoid::Timestamps
    include Geocoder::Model::Mongoid
    include GeoAliases

    # geocoder fields
    field :location_hash,   type: Hash,     default: {}
    field :address,         type: String,   default: nil
    field :coordinates,     type: Array,    default: [] # mongoid stores [long, lat] - backwards convention, geocoder knows this, but [lat, lng]

    geocoded_by :address
    reverse_geocoded_by :coordinates
    before_save :geocode_this_location!
  end

  ##
  #   Check geocoding and reverse geocoding of address <-> lat-lng
  ##
  before(:each) do
    @host = GeoAliasesHost.new
  end

  it :geo_cache_is_empty do
    REDIS.keys.should be_empty
  end

  it :@geocode_address_before_save do
    # '3rd Street Promenade, Santa Monica CA' -> [lat:34.0169509, lng:-118.4977229]
    @host.address.should be_blank
    @host.coordinates.should be_blank
    @host.lat.should be_blank
    @host.lng.should be_blank

    @host.update_attribute(:address,'3rd Street Promenade, Santa Monica CA')
    @host.coordinates.should be_present
    @host.lat.should be_between(33, 35)     # Santa Monica lat is about 34.0169509
    @host.lng.should be_between(-120, -117) # Santa Monica lng is about -118.4977229
    geo_point = @host.geo_point
    @host.lat.should eq geo_point[:lat]     # +++ TODO break out geo point testing into separate spec
    @host.lng.should eq geo_point[:lng]     # +++ TODO break out geo point testing into separate spec
  end

  it :geo_cache_has_1 do
    REDIS.keys.should have(1).things
  end

  it :@geocode_location_hash_before_save do
    # '100 North Lake Blvd, Tahoe City CA 96145' -> [lat: 39.1844571, lng:-120.1227438]
    @host.address.should be_blank
    @host.location_hash.should be_blank
    @host.coordinates.should be_blank
    @host.lat.should be_blank
    @host.lng.should be_blank

    @host.location_hash[:address] = '100 North Lake Blvd'
    @host.location_hash[:city] = 'Tahoe City'
    @host.location_hash[:state] = 'CA'
    @host.location_hash[:zip] = '96145'
    @host.location_hash[:country] = 'USA'

    @host.save!
    @host.address.should_not be_blank
    @host.address.should include 'Tahoe'
    @host.coordinates.should be_present
    @host.lat.should be_between(38, 41)     # Lake Tahoe lat is about 39.1844571
    @host.lng.should be_between(-121, -118) # Lake Tahoe lng is about -120.1227438
  end

  it :geo_cache_has_2 do
    REDIS.keys.should have(2).things
  end


  it :@reverse_geocode_before_save do
    # [lat: 39.1844571, lng:-120.1227438] -> 
    #   '100 North Lake Blvd, Tahoe City CA 96145'  or  
    #   'Tamarack Lodge, Tahoe National Forest, Dollar Point, CA 96145, USA'
    @host.address.should be_blank
    @host.coordinates.should be_blank
    @host.lat.should be_blank
    @host.lng.should be_blank
    geo_point = {lat:39.1844571 , lng:-120.1227438 }
    @host.geo_point = geo_point
    @host.save!
    @host.coordinates.should be_present
    @host.address.should match /Tahoe/
  end

end
