class Craft
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid
  include GeoAliases

  field :rank,            type: Integer,  default: 0
  field :score,           type: Integer,  default: 0
  field :last_tweeted_at, type: DateTime, default: nil

  # geocoder fields
  field :location_hash,   type: Hash,     default: {}
  field :address,         type: String,   default: nil
  field :coordinates,     type: Array,    default: []     # mongoid stores [long, lat] - backwards convention, geocoder knows this, but [lat, lng]

  field :is_mobile,       type: Boolean,  default: false

  # indexed tags
  field :search_tags,     type: Array,    default: []
  field :essence_tags,    type: Array,    default: []     # e.g. food, fit, fun, travel, home
  field :theme_tags,      type: Array,    default: []     # e.g. taco, sushi: weight-loss, yoga, etc

  # statuses
  field :rejected,        type: Boolean,  default: false
  field :approved,        type: Boolean,  default: false

  # embedded web crafts
  embeds_one :twitter_craft
  embeds_one :yelp_craft
  embeds_one :facebook_craft
  embeds_one :website_craft

  index({ search_tags: 1 })
  index({ essence_tags: 1 })
  index({ theme_tags: 1 })

  geocoded_by :address
  reverse_geocoded_by :coordinates
  before_save :geocode_this_location!

  before_save :rerank

  # +++ TODO: add scopes
  # scope with_twitter_craft
  # scope without_twitter_craft
  # scope with_yelp_craft
  # scope without_yelp_craft
  # scope with_facebook_craft
  # scope without_facebook_craft
  # scope with_website_craft
  # scope without_website_craft

  ###
  # rescore!
  # saves with a new score (which also triggers a rerank)
  ###
  def rescore!(score) self.score=score; save! end

  ###
  # score
  # setting score triggers a rerank
  # min score = 0
  # max score = 100
  ###
  def score=(points)
    s = points
    s = 0 if s < 0
    s = 100 if s > 100
    self[:score] = s
    rerank
  end

  ###
  # RERANK! sets the ranking_score and gives it points for being active
  #     More active crafts will be ranked higher
  #     Whenever score is set, the craft automatically gets points for being active.
  #     So if you set craftA.score=10 today, and craftB.score=10 tomorrow then craftB will rank higher than craftA
  #     If you set craftA.score=10 today, and at the same time tomorrow you again set craftA.score=10,
  #     then ranking_score will go up for for craftA by the number of ms in a day (60 * 60 * 24) 86,400
  #
  #     DAY_POINTS
  #     when setting the score, you can think of each point as 1 day
  #     if you set craftA.score = 10 only once
  #     and then you set craftB.score = 1 every day,
  #     then crafB will start to rank higher than craftA after 11 days
  #
  #     calculation:
  #     ranking_score = now + (score * DAY_POINTS)
  #     setting the same score at different times will result in a different ranking_score
  #     The smallest score you can set is 0 (which is still higher than a score of 1 that was set 2 days ago)
  #     ranking_score is represented current unix timestamp (Time.now.to_i) + (score * seconds in a day)
  ###
  DAY_POINTS = (60 * 60 * 24)  # seconds in a day
  def rerank
    s = score * DAY_POINTS
    self.rank = Time.now.to_i + s
  end

  ###
  # materializers
  ###

  def self.materialize(craft_hash=nil)
    return Craft.new if craft_hash.blank?

    twitter_craft_hash  = craft_hash[:twitter_craft]  || craft_hash['twitter_craft']
    facebook_craft_hash = craft_hash[:facebook_craft] || craft_hash['facebook_craft']
    yelp_craft_hash     = craft_hash[:yelp_craft]     || craft_hash['yelp_craft']
    website_craft_hash  = craft_hash[:website_craft]  || craft_hash['website_craft']

    web_crafts = []
    (web_crafts << TwitterCraft.materialize(twitter_craft_hash) ) if twitter_craft_hash.present?
    (web_crafts << FacebookCraft.materialize(facebook_craft_hash) ) if facebook_craft_hash.present?
    (web_crafts << YelpCraft.materialize(yelp_craft_hash) ) if yelp_craft_hash.present?
    (web_crafts << WebsiteCraft.materialize(website_craft_hash) ) if website_craft_hash.present?
    web_crafts.reject!{|wc| wc.nil? }
    crafts = web_crafts.collect(&:craft).reject{|i| i.nil?} # collect all the parent crafts for the web_crafts

    raise "Found multiple crafts bound to these webcrafts" if 1 < crafts.count

    c = crafts.first || Craft.new
    obj_hash = MaterializeUtil.obj_hash(Craft, craft_hash)
    c.assign_attributes(obj_hash)
    c.bind(web_crafts)
  end

  ###
  # WebCraft bindings
  ###
  def bind(web_craft)
    web_craft_list = *web_craft
    web_craft_list.each do |wc|
      build_web_craft(wc)
      self.address = wc.address if (:yelp==wc.provider || ( wc.address.present? and not self.address.present?) )
      self.coordinates = wc.coordinates if (:yelp==wc.provider || ( wc.coordinates.present? and not self.coordinates.present?) )
    end
    self
  end

  def unbind(provider)
    case provider
      when :twitter
        self.twitter_craft = nil
      when :yelp
        self.yelp_craft = nil
      when :facebook
        self.facebook_craft = nil
      when :website
        self.website_craft = nil
      else
        raise "Unknown WebCraft provider: #{provider}"
    end
    self
  end

  ###
  # util
  ###

  def now_active?
    return false # +++ TODO, upcomming schedule? recently tweeted?
  end

  def has_essence(essence_tag) has_tag(:essence, essence_tag) end
  def add_essence(essence_tag) add_tag(:essence, essence_tag) end
  def remove_essence(essence_tag) remove_tag(:essence, essence_tag) end

  def has_theme(theme_tag) has_tag(:theme, theme_tag) end
  def add_theme(theme_tag) add_tag(:theme, theme_tag) end
  def remove_theme(theme_tag) remove_tag(:theme, theme_tag) end

  ###
  # The Craft's Brand
  #   name and description:
  #     Twitter takes precedence, then Facebook, then Yelp
  #     (Twitter and Facebook are owner created, where as yelp may be crowd sourced)
  #   website:
  #     Website url takes precedence, then Twitter, Facebook and Yelp
  ###
  def name
    x = website_craft.name  if website_craft.present?
    x = yelp_craft.name     if yelp_craft.present?
    x = facebook_craft.name if facebook_craft.present?
    x = twitter_craft.name  if twitter_craft.present?
    x
  end

  def description
    x = website_craft.description  if website_craft.present?
    x = yelp_craft.description     if yelp_craft.present?
    x = facebook_craft.description if facebook_craft.present?
    x = twitter_craft.description  if twitter_craft.present?
    x
  end

  def website # Actual web site
    return website_craft.url if website_craft.present?
    x = yelp_craft.website     if (yelp_craft.present?     and :website.eql? yelp_craft.website.provider )
    x = facebook_craft.website if (facebook_craft.present? and :website.eql? facebook_craft.website.provider )
    x = twitter_craft.website  if (twitter_craft.present?  and :website.eql? twitter_craft.website.provider )
    x
  end

  def profile_image_url()             twitter_craft.present? ? twitter_craft.profile_image_url             : nil    end
  def profile_background_tile()       twitter_craft.present? ? twitter_craft.profile_background_tile       : false  end
  def profile_background_color()      twitter_craft.present? ? twitter_craft.profile_background_color      : 'grey' end
  def profile_background_image_url()  twitter_craft.present? ? twitter_craft.profile_background_image_url  : ''     end

  ###
  # convenience
  ###
  def is_mobile?() is_mobile end

  def is_for_food_truck?()
    is_mobile? and is_for_food?
  end
  def set_as_food_truck()
    self.is_mobile = true
    set_as_food!()
  end

  def tweet_stream_id() twitter_craft.present? ? twitter_craft.tweet_stream_id : nil end

  def is_for_food?()  has_essence(:food)    end
  def is_for_fit?()   has_essence(:fitness) end
  def is_for_fun?()   has_essence(:fun)     end
  def is_for_fab?()   has_essence(:fassion) end
  def is_for_fam?()   has_essence(:family)  end
  def is_for_home?()  has_essence(:home)    end

  def set_as_food!()  add_essence(:food)    end
  def set_as_fit!()   add_essence(:fitness) end
  def set_as_fun!()   add_essence(:fun)     end
  def set_as_fab!()   add_essence(:fassion) end
  def set_as_fam!()   add_essence(:family)  end
  def set_as_home!()  add_essence(:home)    end


  def serves_taco?()  has_theme(:taco)      end
  def serves_sushi?() has_theme(:taco)      end
  def serves_bbq?()   has_theme(:taco)      end
  def serves_yoga?()  has_theme(:taco)      end

  def does_taco()     add_theme(:taco)      end
  def does_sushi()    add_theme(:sushi)     end
  def does_bbq()      add_theme(:bbq)       end
  def does_yoga()     add_theme(:yoga)      end

  ###
  # formaters
  ###
  def map_pin # can be dropped onto google maps
    {
      id: _id,
      lat: lat,
      lng: lng,
      name: name,
      website: website,
      now_active: now_active?
    }
  end

private

  def build_web_craft(web_craft)
    case web_craft.provider
      when :twitter
        self.twitter_craft = web_craft
      when :yelp
        self.yelp_craft = web_craft
      when :facebook
        self.facebook_craft = web_craft
      when :website
        self.website_craft = web_craft
      else
        raise "Unknown WebCraft provider: #{web_craft.provider}"
    end
  end

  def has_tag(list_name, tag)
    list_att = "#{list_name}_tags".symbolize
    tags = self[list_att]
    tags.include? tag
  end
  def add_tag(list_name, tag)
    list_att = "#{list_name}_tags".symbolize
    tags = self[list_att]
    return tags if has_tag(list_name, tag)
    tags << tag
    self[list_att] = tags
    save!
    tags
  end
  def remove_tag(list_name, tag)
    list_att = "#{list_name}_tags".symbolize
    tags = self[list_att]
    return tags unless has_tag(list_name, tag)
    tags -= [ tag ]
    self[list_att] = tags
    save!
    tags
  end
end

# see for google maps stuff:
# http://blog.joshsoftware.com/2011/04/13/geolocation-rails-and-mongodb-a-receipe-for-success/

# see :
# GlobalMaps4Rails

# see:
# http://stackoverflow.com/questions/6640697/how-do-i-query-objects-near-a-point-with-ruby-geocoder-mongoid


# see:
# http://stackoverflow.com/questions/6366870/how-to-search-for-nearby-users-using-mongoid-rails-and-google-maps

# lat, lng = Geocoder.search('some location').first.coordinates
# result = Business.near(:location => [lat, lng])

# ‘rake db:mongoid:create_indexes’