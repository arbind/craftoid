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

  end

  describe :ESSENCE_AND_THEME do

    it :@has_essence do
      @craft.mobile?.should_not eq true
      @craft.has_essence?(:food).should_not eq true
      @craft.food_truck = true
      @craft.food_truck?.should eq true
      @craft.mobile?.should eq true
      @craft.has_essence?(:food).should eq true
      @craft.food_truck = false
      @craft.food_truck?.should eq false
      @craft.mobile?.should eq false
      @craft.has_essence?(:food).should eq false
    end

    it :@remove_essence_tag do
      @craft.has_essence?(:food).should_not eq true
      @craft.food_truck = true
      @craft.has_essence?(:food).should eq true
      @craft.remove_essence(:food)
      @craft.has_essence?(:food).should eq false
    end

    it :@has_theme do
      @craft.has_theme?(:taco).should_not eq true
      @craft.add_theme(:taco)
      @craft.has_theme?(:taco).should eq true
    end

    it :@remove_theme_tag do
      @craft.has_theme?(:taco).should_not eq true
      @craft.add_theme(:taco)
      @craft.has_theme?(:taco).should eq true
      @craft.remove_theme(:taco)
      @craft.has_theme?(:taco).should eq false
    end
  end
end