class WebCraft
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid
  include GeoAliases

  # provider info
  field :web_craft_id
  field :username
  field :href # url to page on provider's site  - e.g. facebook.com/pages/:web_craft

  # web_craft info
  field :name
  field :description
  field :website # craft's actual website
  field :location_hash
  field :address, default: nil
  field :coordinates, type: Array, default: []

  geocoded_by :address
  reverse_geocoded_by :coordinates

  after_initialize :format_attributes
  before_save :format_attributes
  before_save :geocode_this_location!

  # convert classname to provider name: e.g. TwitterCraft -> :twitter
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

    web_craft.assign_attributes(subject_attributes)
    web_craft
  end

  def self.materialize_for_web_craft_id(wc_id)
    craft = Craft.where('#{web_craft_type}.web_craft_id' => wc_id).first
    return craft[web_craft_type] if craft
    return new({web_craft_id: wc_id})
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
    # urlify
    self.website = website.downcase.urlify! if website.looks_like_url?
    self.href = href.downcase.urlify! if href.looks_like_url?
  end

  def geocode_this_location!
    if self.lat.present? and (new? or changes[:coordinates].present?)
      reverse_geocode # udate the address
    elsif location_hash.present? and not self.lat.present? and (new? or changes[:location_hash].present?)
      l = []
      (l << location_hash[:address]) if location_hash[:address].present?
      (l << location_hash[:city]) if location_hash[:city].present?
      (l << location_hash[:state]) if location_hash[:state].present?
      (l << location_hash[:zip]) if location_hash[:zip].present?
      (l << location_hash[:country]) if location_hash[:country].present?
      self.address = l.join(', ') if l.present?
      geocode # update lat, lng
    end
    return true
  end

end
