class Craft
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid
  include GeoAliases

  field :rank           , type: Integer,  default: 0
  field :score          , type: Integer,  default: 0

  # geocoder fields
  field :location_hash  , type: Hash,     default: {}
  field :address        , type: String,   default: nil
  field :coordinates    , type: Array,    default: []     # mongoid stores [long, lat] - backwards convention, geocoder knows this, but [lat, lng]

  # organizers
  field :mobile         , type: Boolean

  # indexed tags
  field :search_tags    , type: Array
  field :essence_tags   , type: Array     # e.g. food, fit, fun, travel, home
  field :theme_tags     , type: Array     # e.g. taco, sushi: weight-loss, yoga, etc

  # embedded web crafts
  embeds_one :twitter   , class_name: 'TwitterCraft'
  embeds_one :yelp      , class_name: 'YelpCraft'
  embeds_one :facebook  , class_name: 'FacebookCraft'
  embeds_one :website   , class_name: 'WebsiteCraft'

  before_save         :geocode_this_location!
  geocoded_by         :address
  reverse_geocoded_by :coordinates

  before_save         :rerank

  # indexes
  index({ search_tags: 1 })
  index({ essence_tags: 1 })
  index({ theme_tags: 1 })

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
  # organizers
  ###

  # :food, :fitness, :fun, :fab, :fashion, :family, :home
  def has_essence?(essence_tag) has_tag(:essence, essence_tag) end
  def add_essence(essence_tag) add_tag(:essence, essence_tag) end
  def remove_essence(essence_tag) remove_tag(:essence, essence_tag) end

  # :taco, :sushi, :bbq, :yoga
  def has_theme?(theme_tag) has_tag(:theme, theme_tag) end
  def add_theme(theme_tag) add_tag(:theme, theme_tag) end
  def remove_theme(theme_tag) remove_tag(:theme, theme_tag) end

  def food_truck?()
    mobile? and has_essence?(:food)
  end

  def food_truck=(bool)
    self.mobile = bool
    if bool
      add_essence(:food)
    else
      remove_essence(:food) if !bool
    end
  end

  def tweet_stream_id() twitter.present? ? twitter.tweet_stream_id : nil end

private

  def has_tag(list_name, tag)
    list_att = "#{list_name}_tags".symbolize
    tags = self[list_att]
    tags and tags.include? tag
  end

  def add_tag(list_name, tag)
    list_att = "#{list_name}_tags".symbolize
    self[list_att] ||= []
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
    return tags unless tags and has_tag(list_name, tag)
    tags -= [ tag ]
    self[list_att] = tags
    save!
    tags
  end
end

# see for google maps stuff:
# http://blog.joshsoftware.com/2011/04/13/geolocation-rails-and-mongodb-a-receipe-for-success/

# ###
# # formaters
# ###
# def map_pin # can be dropped onto google maps
#   {
#     id: _id,
#     lat: lat,
#     lng: lng,
#     name: name,
#     website: website_url,
#     now_active: now_active?
#   }
# end

# see :
# GlobalMaps4Rails

# see:
# http://stackoverflow.com/questions/6640697/how-do-i-query-objects-near-a-point-with-ruby-geocoder-mongoid

# see:
# http://stackoverflow.com/questions/6366870/how-to-search-for-nearby-users-using-mongoid-rails-and-google-maps

# lat, lng = Geocoder.search('some location').first.coordinates
# result = Business.near(:location => [lat, lng])

# ‘rake db:mongoid:create_indexes’