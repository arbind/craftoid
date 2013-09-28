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
  let (:subject)            { clazz.new subject_attributes }

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
end
