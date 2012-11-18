class Craft
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid
  include GeoAliases

  field :ranking_score,   type: Integer, default: 0
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

  index :search_tags
  index :essence_tags
  index :theme_tags

  geocoded_by :address
  reverse_geocoded_by :coordinates
  before_save :geocode_this_location!

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
#   SCORE: sets the ranking_score and gives it points for being active
#     More active crafts will be ranked higher
#     Whenever score is set, the craft automatically gets points for being active.
#     So if you set craftA.score=10 today, and craftB.score=10 tomorrow then craftB will rank higher than craftA
#     If you set craftA.score=10 today, and at the same time tomorrow you again set craftA.score=10,
#     then ranking_score will go up for for craftA by the number of ms in a day (1000 * 60 * 60 * 24) 86,400,000
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
#     ranking_score is represented current unix timestamp (Time.now.to_i) plus score * milliseconds in a day
### 
  DAY_POINTS = (1000 * 60 * 60 * 24)  # milliseconds in a day
  def score=(score)
    s = score * DAY_POINTS
    s = 0 if s < 0
    rank = Time.now.to_i + s
    update_attribute(ranking_score: rank)
  end

###
#   formaters
###
  def map_pins # can be dropped onto google maps
    {
      "#{_id}" => {
        name: name,
        lat: lat,
        lng: lng,
        website: website,
        now_active: now_active?
      }
    }
  end

###
#   WebCraft bindings
###
  def bind(web_craft)
    web_craft_list = *web_craft 
    web_craft_list.each do |wc|
      build_web_craft(wc)
      self.address = wc.address if (:yelp==wc.provider || ( wc.address.present? and not self.address.present?) )
      self.coordinates = wc.coordinates if (:yelp==wc.provider || ( wc.coordinates.present? and not self.coordinates.present?) )
    end
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
  end

###
#   convenience
###
  def is_mobile?( )is_mobile end

  def is_for_food_truck?()
    is_mobile? and is_for_food?
  end
  def set_as_food_truck()
    self.is_mobile = true
    set_as_food!()
  end

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


  def serves_taco?()    has_theme(:taco)    end
  def serves_sushi?()   has_theme(:taco)    end
  def serves_bbq?()     has_theme(:taco)    end
  def serves_yoga?()    has_theme(:taco)    end

  def does_taco()    add_theme(:taco)       end
  def does_sushi()   add_theme(:sushi)      end
  def does_bbq()     add_theme(:bbq)        end
  def does_yoga()    add_theme(:yoga)       end


  # Derive the Craft's Brand
  def name
    x = twitter_craft.name if twitter_craft.present?
    x ||= yelp_craft.name if yelp_craft.present?
    x ||= facebook_craft.name if facebook_craft.present?
    x
  end

  def description
    x = twitter_craft.description if twitter_craft.present?
    x ||= yelp_craft.description if yelp_craft.present?
    x ||= facebook_craft.description if facebook_craft.present?
    x
  end

  def website
    # first see if there is a website specified
    x = yelp_craft.website if yelp_craft.present?
    x ||= twitter_craft.website if twitter_craft.present?
    x ||= facebook_craft.website if facebook_craft.present?
    # if not, look for an href to a service
    x ||= twitter_craft.href if twitter_craft.present?
    x ||= facebok_craft.href if facebook_craft.present?
    x ||= yelp_craft.href if yelp_craft.present?
    x
  end

  def profile_image_url
    x = twitter_craft.profile_image_url if twitter_craft.present?
    #+++ TODO ||= facebook profile image
    x
  end
  def profile_background_color
    x = twitter_craft.profile_background_color if twitter_craft.present?
    x ||= 'grey'
    x
  end
  def profile_background_image_url
    x = twitter_craft.profile_background_image_url if twitter_craft.present?
    x ||= ''
    x
  end
  def profile_background_tile
    if twitter_craft.present?
      x = twitter_craft.profile_background_tile
    else
      x = false 
    end
    x
  end
  # Craft Branding

  # convenient delegations
  def now_active?
    time = last_tweeted_at
    return false if time.nil?

    time = time + (-Time.zone_offset(Time.now.zone))
    2.days.ago < time # consider this craft to be active if there was a tweet in the last 2 days
  end

  def tweet_stream_id
    twitter_craft.present? ? twitter_craft.tweet_stream_id : nil
  end

  def how_long_ago_was_last_tweet
    return @how_long_ago_was_last_tweet if @how_long_ago_was_last_tweet.present?
    x = Util.how_long_ago_was(last_tweeted_at) if last_tweeted_at.present?
    x ||= nil
    @how_long_ago_was_last_tweet = x
  end


###
#   util
###
  def has_essence(essence)
    has_tag(:essence, essence_tag)
  end
  def add_essence(essence_tag)
    add_tag(:essence, essence_tag)
  end
  def remove_essence(essence_tag)
    remove_tag(:essence, essence_tag)
  end

  def has_theme(theme)
    has_tag(:theme, theme_tag)
  end
  def add_theme(theme_tag)
    add_tag(:theme, theme_tag)
  end
  def remove_theme(theme_tag)
    remove_tag(:theme, theme_tag)
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
    tags = self[list_name]
    tags.include? tag
  end
  def add_tag(list_name, tag)
    tags = self[list_name]
    return tags if has_tag(list_name, tag)
    tags << tag
    self[list_name] = tags
    save!
    tags
  end
  def remove_tag(list_name, tag)
    tags = self[list_name]
    return tags if has_tag(list_name, tag)
    tags -= [ tag ]
    self[list_name] = tags
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