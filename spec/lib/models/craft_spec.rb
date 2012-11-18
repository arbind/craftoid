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
      @craft.is_mobile?.should eq false
      @craft.is_for_food?.should eq false
      @craft.is_for_food_truck?.should eq false
      @craft.set_as_food_truck
      @craft.is_mobile?.should eq true
      @craft.is_for_food?.should eq true
      @craft.is_for_food_truck?.should eq true
    end

    it :@remove_essence_tag do
      @craft.is_for_food_truck?.should eq false
      @craft.set_as_food_truck
      @craft.is_for_food_truck?.should eq true
      @craft.remove_essence(:food)
      @craft.is_for_food_truck?.should eq false
    end

    it :@serves_taco do
      @craft.serves_taco?.should eq false
      @craft.does_taco
      @craft.serves_taco?.should eq true
    end

    it :@remove_theme_tag do
      @craft.serves_taco?.should eq false
      @craft.does_taco
      @craft.serves_taco?.should eq true
      @craft.remove_theme(:taco)
      @craft.serves_taco?.should eq false
    end

  end

end