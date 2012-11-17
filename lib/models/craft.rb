class Craft
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid
  include GeoAliases

  BILLION = 1000000000

  field :ranking_score, type: Integer, default: 0

  # geocoder fields
  # mongoid stores [long, lat] - which is backwards from normal convention
  # geocoder knows this, but expects [lat, lng]
  field :location_hash, type: Hash
  field :address, default: nil
  field :coordinates, type: Array, default: []

  field :is_mobile, type: Boolean, default: false

  field :search_tags, type: Array, default: []
  field :essence_tags, type: Array, default: []     # e.g. food, fit, fun, travel, home
  field :theme_tags, type: Array, default: []       # e.g. truck, taco, sushi: weight-loss, yoga, etc
  # field :id_tags, type: Array, default: []        # e.g. fb:facebook_id, yelp:yelp_id, @twitter_id etc.
  # field :username_tags, type: Array, default: []  # e.g. fb:username, @twitter_handle

  # statuses
  field :rejected, type: Boolean, default: false
  field :approved, type: Boolean, default: false

  # web crafts
  embeds_one :twitter_craft
  embeds_one :yelp_craft
  embeds_one :facebook_craft
  embeds_one :website_craft

  index :search_tags
  index :essence_tags
  index :theme_tags

  geocoded_by :address
  reverse_geocoded_by :coordinates
  before_save :geocode_this_location! # auto-fetch coordinates

  # +++ TODO: add scopes
  # scope with_twitter_craft
  # scope without_twitter_craft
  # scope with_yelp_craft
  # scope without_yelp_craft
  # scope with_facebook_craft
  # scope without_facebook_craft
  # scope with_website_craft
  # scope without_website_craft

  ### SCORE
  #     The smallest score you can set is 0, the largest is 1 Billion
  #     ranking_score is represented as a negative offset from the current unix timestamp (Time.now.to_i)
  #     Setting the score changes with time:
  #     if today you set craft1.score = 0 and tomorrow you set craft2.score = 0 then craft2 will have a higher ranking_score
  #     (current unix timestamp are greater than 1Billion)
  ### 
  def score=(score)
    s = score
    s = 0 if score < 0
    s = BILLION if score > BILLION
    rank = Time.now.to_i - BILLION + s
    update_attribute(ranking_score: rank)
  end

  def tweet_stream_id
    twitter_craft.present? ? twitter_craft.tweet_stream_id : nil
  end

  def is_mobile?
    is_mobile
  end

  def is_for_mobile_cuisine?
    has_essence(:mobile_cuisine)
  end

  def is_for_food?
    has_essence(:food)
  end
  def is_for_fitness?
    has_essence(:fitness)
  end
  def is_for_fun?
    has_essence(:fun)
  end
  def is_for_home?
    has_essence(:home)
  end

  alias_method :is_for_food_truck?, :is_for_mobile_cuisine?
  alias_method :is_for_foodtruck?, :is_for_mobile_cuisine?

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

  def map_pins
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

  def bind(web_craft)
    web_craft_list = *web_craft 
    web_craft_list.each do |wc|
      build_web_craft(wc)
      self.address = wc.address if (:yelp==wc.provider || ( wc.address.present? and not self.address.present?) )
      self.coordinates = wc.coordinates if (:yelp==wc.provider || ( wc.coordinates.present? and not self.coordinates.present?) )
    end
  end

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

  def last_tweet_html
    if twitter_craft.present? and twitter_craft.oembed.present?
      x = twitter_craft.oembed['html'].html_safe
    else
      x = nil
    end
    x
  end

  def how_long_ago_was_last_tweet
    return @how_long_ago_was_last_tweet if @how_long_ago_was_last_tweet.present?
    x = Util.how_long_ago_was(last_tweeted_at) if last_tweeted_at.present?
    x ||= nil
    @how_long_ago_was_last_tweet = x
  end

  def now_active?
    time = last_tweeted_at
    return false if time.nil?

    time = time + (-Time.zone_offset(Time.now.zone))
    2.days.ago < time # consider this craft to be active if there was a tweet in the last 2 days
  end

  def last_tweeted_at
    return @last_tweeted_at if @last_tweeted_at.present?
    # if twitter.present? and twitter.timeline.present? and twitter.timeline.first.present? and twitter.timeline.first["created_at"].present?      
    #   @last_tweeted_at = twitter.timeline.first["created_at"]
    #   @last_tweeted_at = @last_tweeted_at.to_time if @last_tweeted_at.present?
    # else
    #   @last_tweeted_at = nil
    # end
    @last_tweeted_at
  end

private

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