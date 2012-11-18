##
#   Shared Spec for subclasses of WebCraft
#     eg: TwitterCraft, FacebookCraft, YelpCraft, WebsiteCraft (all of which inherit behaviour from WebCraft)
##

shared_examples :WebCraft do |subclass_info|

  ##
  #   Define indicators for this provider
  ##
  let (:provider_key)       { subclass_info[:provider][:key] }      # eg: '@' or 'fb' or 'yelp'
  let (:provider_symbol)    { subclass_info[:provider][:symbol] }   # eg: :twitter or :facebook or :yelp

  ##
  #   Define clazz (subclass of WebCraft) and corresponding accessor
  ##
  let (:clazz)              { subclass_info[:clazz] }   # eg: TwitterCraft
  let (:craft_accessor)     { clazz.name.underscore }   # eg: twitter_craft - craft.send(craft_accessor) calls craft.twitter_craft

  ##
  #   Define a test subject as an instance of the subclass
  ##
  let (:subject_id)         { subclass_info[:subject][:id] }      # eg: 45345, or '45677', or yelp-biz-name', or 'http://mysite.com'. etc.
  let (:subject_handle)     { subclass_info[:subject][:handle] }  # eg: username or handle
  let (:subject_attributes) { subclass_info[:subject][:attributes].merge({'web_craft_id'=>subject_id, 'username'=>subject_handle}) }
  subject                   { clazz.new subject_attributes }

  ##
  #   Check that the subclass exists
  #   eg: clazz = TwitterCraft 
  ##
  specify { clazz.should_not be_nil }
  specify { subject.should be_an_instance_of clazz }

  ##
  #   Check the id of an instance (subject)
  ##
  specify { subject.web_craft_id.should be_an_instance_of String }
  specify { subject.web_craft_id.should eq subject_id.to_s }
  specify { subject.id_for_fetching.should eq subject_handle }

  ##
  #   Check basic class methods
  ##
  it :@@provider do # @@class_method
    clazz.provider.should equal provider_symbol
  end
  it :@@provider_key do
    clazz.provider_key.should eq provider_key
  end

  ##
  #   Check basic instance methods 
  #   eg: subject = TwitterCraft.new (atts)
  ##
  it :@provider do # @instance_method
    subject.provider.should equal provider_symbol
  end
  it :@provider_key do
    subject.provider_key.should eq provider_key
  end

  ##
  #   Sanity Check geocoding (full geocoding spec handled by GeoAliases mixin spec)
  ##
  context :GeoCoder do
    before(:each) do
      atts = subject_attributes.deep_dup
      atts.delete(:address)
      atts.delete(:coordinates)
      @webcraft = clazz.materialize(atts)
      @craft = Craft.new
      @craft.bind(@webcraft)
    end
    after(:each) do
      @craft.delete # deleting the parent craft also deletes the embedded webcraft
    end

    it :@geocode_address_before_save do
      # '3rd Street Promenade, Santa Monica CA' -> [lat:34.0169509, lng:-118.4977229]
      @webcraft.address.should be_blank
      @webcraft.coordinates.should be_blank
      @webcraft.lat.should be_blank
      @webcraft.lng.should be_blank

      @webcraft.update_attribute(:address,'3rd Street Promenade, Santa Monica CA')
      @webcraft.coordinates.should be_present
      @webcraft.lat.should be_between(33, 35)     # Santa Monica lat is about 34.0169509
      @webcraft.lng.should be_between(-120, -117) # Santa Monica lng is about -118.4977229
      geo_point = @webcraft.geo_point
      @webcraft.lat.should eq geo_point[:lat]     # +++ TODO break out geo point testing into separate spec
      @webcraft.lng.should eq geo_point[:lng]     # +++ TODO break out geo point testing into separate spec
    end

  end

  ##
  #   Check materializing a new instance
  ##
  context :when_subject_doesnt_exist do
    it :@@materialize do
      wc = clazz.materialize(subject_attributes)
      wc.should_not be_nil
      wc.web_craft_id.should eq subject_id.to_s
    end

    it :@@materialize_works_with_string_id do
      wc = clazz.materialize({web_craft_id: subject_id.to_s})
      wc.should_not be_nil
      wc.web_craft_id.should eq subject_id.to_s
    end

    it :@@materialize_craft_is_nil do
      wc = clazz.materialize(subject_attributes)
      wc.should_not be_nil
      wc.craft.should be_nil
    end
  end

  ##
  #   Check materializing an existing instance
  ##
  context :when_subject_already_exists do
    before(:all) do
      c = Craft.new
      c.bind(subject)
      c.save
    end
    after(:all) do
      subject.craft.delete # deleting the parent craft also deletes the embedded webcraft
    end

    it :@@materialize do
      wc = clazz.materialize(subject_attributes)
      wc.should_not be_nil
      wc.web_craft_id.should eq subject_id.to_s
      wc.username.should eq subject_handle
      wc.craft.should_not be_nil
      wc.craft.send(craft_accessor).should eq wc
    end

    it :@@materialize_works_with_string_id do
      wc = clazz.materialize({web_craft_id: subject_id.to_s})
      wc.should_not be_nil
      wc.web_craft_id.should eq subject_id.to_s
      wc.username.should eq subject_handle
    end

    it :@@materialize_craft_exists do
      wc = clazz.materialize({ web_craft_id: subject_id })
      wc.should_not be_nil
      wc.craft.should_not be_nil
      wc.craft.send(craft_accessor).should eq wc
    end

    it :@@materialize_will_assign_new_attributes do
      old_name = subject_attributes[:name]
      old_desc = subject_attributes[:description]

      new_postfix = Time.now.to_i.to_s
      new_name = "A New Name " << new_postfix
      new_desc = "A New Description " << new_postfix
      new_atts = subject_attributes.merge({name: new_name, description:new_desc})

      wc = clazz.materialize(new_atts)

      wc.name.should_not eq old_name
      wc.description.should_not eq old_desc

      wc.name.should eq new_name
      wc.description.should eq new_desc
    end

  end

  ##
  #   Check materializing from invalid attributes
  ##
  context :invalid_id do
    it :@@materialize do
      wc = clazz.materialize( {has_no_web_craft_id:true} )
      wc.should be_nil
    end
  end

end
