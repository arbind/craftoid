require 'spec_helper'

describe :Craft do
  specify { Craft.should_not be_nil }  

  context :MATERIALIZE_AND_BIND do

  # materialize:
  # def materialize(craft)
  # def bind(web_craft)
  # def unbind(provider)
  end


  context :SCORE_AND_RANK do
    before(:each) do
      @craft = Craft.new
    end
    after(:each) do
      @craft.delete
    end

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

  context :RECENT_ACTIVITY do
  # activity:
  # def now_active?
  # def how_long_ago_was_last_tweet
  end

  context :BRANDING do
  # branding:
  # def name
  # def description
  # def website
  end

  context :GEOCODING_AND_MAPPING do
    # def map_pins
    before(:each) do
      @craft = Craft.new
    end
    after(:each) do
      @craft.delete
    end

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
  end

  context :ESSENCE_AND_THEME do
    before(:each) do
      @craft = Craft.new
    end
    after(:each) do
      @craft.delete
    end

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


  # def serves_taco?()    has_theme(:taco)    end
  # def does_taco()    add_theme(:taco)       end
  end

end