require 'spec_helper'

describe :Craft do
  specify { Craft.should_not be_nil }
  subject { Craft.new }

  before(:each) do
    @craft = Craft.new
  end
  after(:each) do
    @craft.delete
  end


  ##
  #   Check materializing a new instance
  ##
  context :WHEN_SUBJECT_DOESNT_EXIST do
    it :@@materialize_empty do
      c = Craft.materialize()
      c.should_not be_nil
    end

    it :@@materialize_with_web_crafts do
      y = YelpCraft.new(    {name: 'yelp-name',     description: 'yelp-name',     website: 'my-site.com', href: 'yelp.com/my-yelp'})
      w = WebsiteCraft.new( {name: 'website-name',  description: 'website-name',  website: 'my-site.com', href: 'website.com/my-website'})
      t = TwitterCraft.new( {name: 'twitter-name',  description: 'twitter-name',  website: 'my-site.com', href: 'twitter.com/my-twitter'})
      f = FacebookCraft.new({name: 'facebook-name', description: 'facebook-name', website: 'my-site.com', href: 'facebook.com/my-facebook'})

      subject_attributes = {}
      subject_attributes[:score] = 22
      subject_attributes[:yelp_craft] = y.attributes
      subject_attributes[:website_craft] = w.attributes
      subject_attributes[:twitter_craft] = t.attributes
      subject_attributes[:facebook_craft] = f.attributes

      c = Craft.materialize(subject_attributes)

      c.should_not be_nil
      (1+c.score).should eq 1+subject_attributes[:score] # ensure score is an Integer by adding 1

      c.yelp_craft.yelp_id.should eq y.yelp_id
      c.twitter_craft.screen_name.should eq t.screen_name
      c.website_craft.url.should eq w.url
      c.facebook_craft.web_craft_id.should eq f.web_craft_id
    end
  end

  ##
  #   Check materializing an existing instance
  ##
  context :WHEN_SUBJECT_ALREADY_EXIST do
    before(:all) do
      # save a craft with embedded web crafts
      @savedW = WebsiteCraft.new( {web_craft_id: 'saved-website-id',  username: '', name: 'saved-website-name',  description: 'saved-website-name',  website: 'my-saved-site.com', href: 'website.com/my-saved-website'})
      @savedF = FacebookCraft.new({web_craft_id: 'saved-facebook-id', username: '', name: 'saved-facebook-name', description: 'saved-facebook-name', website: 'my-saved-site.com', href: 'facebook.com/my-saved-facebook'})
      @savedT = TwitterCraft.new( {web_craft_id: '1234',       username: 'mytruck', name: 'saved-twitter-name',  description: 'saved-twitter-name',  website: 'my-saved-site.com', href: 'twitter.com/my-saved-twitter'})
      @savedY = YelpCraft.new(    {web_craft_id: 'saved-yelp-id',     username: '', name: 'saved-yelp-name',     description: 'saved-yelp-name',     website: 'my-saved-site.com', href: 'yelp.com/my-saved-yelp'})
      @savedWebcrafts = [@savedW, @savedF, @savedT, @savedY]
      @savedC = Craft.new
      @savedC.bind(@savedWebcrafts)
      @savedC.save

      # save another craft with a twitter craft
      @savedT2 = TwitterCraft.new( {name: 'saved2-twitter-name',  description: 'saved2-twitter-name',  website: 'my-saved2-site.com', href: 'twitter.com/my-saved2-twitter2'})
      @savedC2 = Craft.new
      @savedC2.bind(@savedT2)
      @savedC2.save
    end

    after(:all) do
      @savedC.delete
      @savedC2.delete
    end

    it :@@materialize_from_a_web_craft do
      subject_attributes = {}
      subject_attributes[:score] = 42
      subject_attributes[:twitter_craft] = @savedT.attributes

      c = Craft.materialize(subject_attributes) # should find the saved craft, fully populated with all other web crafts

      c.should_not be_nil
      (1+c.score).should eq 1+subject_attributes[:score] # ensure score is an Integer by adding 1

      c.yelp_craft.yelp_id.should eq @savedY.yelp_id
      c.twitter_craft.screen_name.should eq @savedT.username
      c.website_craft.url.should eq @savedW.url
      c.facebook_craft.web_craft_id.should eq @savedF.web_craft_id
    end

    ##
    #   Check materializing from invalid attributes
    ##
    it :@@materialize_raises do
      subject_attributes = {}
      subject_attributes[:yelp_craft] = @savedY.attributes      # bound to @savedC
      subject_attributes[:twitter_craft] = @savedT2.attributes  # bound to @savedC2 - a different craft

      lambda {Craft.materialize(subject_attributes)}.should raise_error # embeded web_crafts in attributes are bound to different crafts
    end

  end


  context :WITH_WEBCRAFTS do

    before(:each) do
      @w = WebsiteCraft.new( {name: 'website-name',  description: 'website-name',  website: 'my-site.com', href: 'website.com/my-website'})
      @f = FacebookCraft.new({name: 'facebook-name', description: 'facebook-name', website: 'my-site.com', href: 'facebook.com/my-facebook'})
      @t = TwitterCraft.new( {name: 'twitter-name',  description: 'twitter-name',  website: 'my-site.com', href: 'twitter.com/my-twitter'})
      @y = YelpCraft.new(    {name: 'yelp-name',     description: 'yelp-name',     website: 'my-site.com', href: 'yelp.com/my-yelp'})
      @x = WebCraft.new (    {name: 'bad-name',      description: 'bad-name',      website: 'my-bad.com',  href: 'bad.com/my-bad'})
      @webcrafts = [@w, @f, @t, @y]
    end
    after(:each) do
    end

    it :@bind_one do
      @craft.twitter_craft.should be_nil
      @craft.yelp_craft.should be_nil
      @craft.facebook_craft.should be_nil
      @craft.website_craft.should be_nil

      @craft.bind(@t)
      @craft.twitter_craft.should eq @t
      @craft.bind(@y)
      @craft.yelp_craft.should eq @y
      @craft.bind(@f)
      @craft.facebook_craft.should eq @f
      @craft.bind(@w)
      @craft.website_craft.should eq @w
    end

    it :@bind_many do
      @craft.twitter_craft.should be_nil
      @craft.yelp_craft.should be_nil
      @craft.facebook_craft.should be_nil
      @craft.website_craft.should be_nil

      @craft.bind(@webcrafts)

      @craft.twitter_craft.should eq @t
      @craft.yelp_craft.should eq @y
      @craft.facebook_craft.should eq @f
      @craft.website_craft.should eq @w
    end

    it :@bind_raises_exception do
      lambda { @craft.bind(@x) }.should raise_error
    end


    it :@unbind do
      webcrafts = [@w, @f, @t, @y]
      @craft.bind(webcrafts)

      @craft.twitter_craft.should eq @t
      @craft.yelp_craft.should eq @y
      @craft.facebook_craft.should eq @f
      @craft.website_craft.should eq @w

      @craft.unbind(:twitter)
      @craft.twitter_craft.should be_nil
      @craft.unbind(:yelp)
      @craft.yelp_craft.should be_nil
      @craft.unbind(:facebook)
      @craft.facebook_craft.should be_nil
      @craft.unbind(:website)
      @craft.website_craft.should be_nil
    end

    it :@unbind_raises_exception do
      lambda { @craft.unbind(:bad_craft) }.should raise_error
    end
    describe :BRANDING do

      it :twitter_takes_precedence do
        @craft.name.should be_nil
        @craft.description.should be_nil
        @craft.website.should be_nil

        @craft.bind(@y)
        @craft.name.should        eq @y.name
        @craft.description.should eq @y.description
        @craft.website.should     eq @y.website

        @craft.bind(@f) # facebook_craft overrides yelp_craft
        @craft.name.should        eq @f.name
        @craft.description.should eq @f.description
        @craft.website.should     eq @f.website

        @craft.bind(@t) # twitter_craft overrides facebook_craft
        @craft.name.should        eq @t.name
        @craft.description.should eq @t.description
        @craft.website.should     eq @t.website

        @craft.bind(@w) # website_craft overrides for url, but not for name or description
        @craft.website.should     eq @w.website # actual website takes precedence
        @craft.name.should        eq @t.name # name and description still come from twitter
        @craft.description.should eq @t.description
      end

    end # describe :BRANDING

  end # context :WITH_WEBCRAFTS


  describe :SCORE_AND_RANK do

    it :@score_min_max do
      @craft.score.should eq 0
      @craft.score = 101
      @craft.score.should eq 100
      @craft.score = -1
      @craft.score.should eq 0
      @craft.score = 88
      @craft.score.should eq 88
      @craft.score = 8
      @craft.score.should eq 8
    end

    it :@score_triggers_rerank do
      @craft.score = 50
      rankA = @craft.rank
      @craft.score = 99
      rankB = @craft.rank
      rankA.should be < rankB
    end

    it :@rerank_is_time_dependent do
      same_score = 77
      @craft.score = same_score
      rankA = @craft.rank
      sleep(1)
      @craft.score = same_score
      rankB = @craft.rank
      rankA.should be < rankB
    end

  end

  describe :GEOCODING do

    it :@geocode_address_before_save do
      # '3rd Street Promenade, Santa Monica CA' -> [lat:34.0169509, lng:-118.4977229]
      @craft.address.should be_blank
      @craft.coordinates.should be_blank
      @craft.lat.should be_blank
      @craft.lng.should be_blank

      @craft.update_attribute(:address,'3rd Street Promenade, Santa Monica CA')
      @craft.coordinates.should be_present
      @craft.lat.should be_between(33, 35)     # Santa Monica lat is about 34.0169509
      @craft.lng.should be_between(-120, -117) # Santa Monica lng is about -118.4977229
      geo_point = @craft.geo_point
      @craft.lat.should eq geo_point[:lat]     # +++ TODO break out geo point testing into separate spec
      @craft.lng.should eq geo_point[:lng]     # +++ TODO break out geo point testing into separate spec
    end

      it :@map_pins do
        @t = TwitterCraft.new( {name: 'twitter-name',  description: 'twitter-name',  website: 'my-site.com', href: 'twitter.com/my-twitter'})
        @craft.bind(@t)

        @craft.update_attribute(:address,'3rd Street Promenade, Santa Monica CA')
        @craft.coordinates.should be_present
        @craft.lat.should be_between(33, 35)     # Santa Monica lat is about 34.0169509
        @craft.lng.should be_between(-120, -117) # Santa Monica lng is about -118.4977229

        pin = @craft.map_pin
        pin.should be_present
        pin[:id].should eq @craft._id
        pin[:lat].should be_between(33, 35)     # Santa Monica lat is about 34.0169509
        pin[:lng].should be_between(-120, -117) # Santa Monica lng is about -118.4977229
        pin[:name].should eq @t.name
        pin[:website].should eq @t.website
      end

  end

  describe :ESSENCE_AND_THEME do

    it :@is_for_food_truck do
      @craft.is_mobile?.should_not eq true
      @craft.is_for_food?.should_not eq true
      @craft.is_for_food_truck?.should_not eq true
      @craft.set_as_food_truck!
      @craft.is_mobile?.should eq true
      @craft.is_for_food?.should eq true
      @craft.is_for_food_truck?.should eq true
    end

    it :@remove_essence_tag do
      @craft.is_for_food_truck?.should_not eq true
      @craft.set_as_food_truck!
      @craft.is_for_food_truck?.should eq true
      @craft.remove_essence(:food)
      @craft.is_for_food_truck?.should eq false
    end

    it :@serves_taco do
      @craft.serves_taco?.should_not eq true
      @craft.does_taco
      @craft.serves_taco?.should eq true
    end

    it :@remove_theme_tag do
      @craft.serves_taco?.should_not eq true
      @craft.does_taco
      @craft.serves_taco?.should eq true
      @craft.remove_theme(:taco)
      @craft.serves_taco?.should eq false
    end

  end

end