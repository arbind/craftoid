class WebCraft
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid
  include GeoAliases

  # provider info
  field :web_craft_id
  field :username
  field :href # url to provider's site e.g. facebook.com/pages/:web_craft_id

  # web_craft info
  field :name
  field :description
  field :website # actual website for the craft

  field :location_hash, type: Hash, default: {}
  field :address, default: nil
  field :coordinates, type: Array, default: []

  geocoded_by :address
  reverse_geocoded_by :coordinates

  # before_save :geocode_this_location!

  def self.provider
    name[0..-6].symbolize
  end
  def self.provider_key
    name[0..-6].downcase
  end
  def self.web_craft_type
    name.underscore # e.g. twitter_craft, yelp_craft, facebook_craft, website_craft, etc.
  end

  def provider
    self.class.provider
  end
  def provider_key
    self.class.provider_key
  end

end
