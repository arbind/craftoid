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

  after_initialize :format_attributes
  before_save :format_attributes
  before_save :geocode_this_location!

  def self.provider
    name[0..-6].symbolize
  end
  def self.provider_key
    name[0..-6].downcase
  end
  def self.web_craft_type
    name.underscore # e.g. twitter_craft, yelp_craft, facebook_craft, website_craft, etc.
  end

  def self.materialize(web_craft_hash)
    wc_id = web_craft_hash[:web_craft_id] || web_craft_hash['web_craft_id']
    return nil if wc_id.nil?

    wc_id = wc_id.to_s # make sure web_craft_id is a String prior to looking it up
    web_craft = materialize_for_web_craft_id(wc_id)

    # assign all the attributes
    subject_attributes = web_craft_hash.deep_dup
    subject_attributes.delete(:web_craft_id)
    subject_attributes.delete('web_craft_id')
    subject_attributes[:web_craft_id] = wc_id

    obj_hash = MaterializeUtil.obj_hash(self, subject_attributes)
    web_craft.assign_attributes(obj_hash)
    web_craft
  end

  def self.materialize_for_web_craft_id(wc_id)
    # see if a web_craft already exists by this wc_id
    craft = Craft.where("#{web_craft_type}.web_craft_id" => wc_id).first
    web_craft   = craft.send(web_craft_type) if craft
    web_craft ||= new( {web_craft_id: wc_id} ) # create a new web_craft by wc_id if one wasnt found
    web_craft
  end

  def provider
    self.class.provider
  end
  def provider_key
    self.class.provider_key
  end
  def id_for_fetching
    web_craft_id
  end

  private

  def format_attributes
    self.web_craft_id = web_craft_id.to_s
    self.website = website.downcase.urlify! if website.looks_like_url?
    self.href    = href.downcase.urlify! if href.looks_like_url?
  end

end
