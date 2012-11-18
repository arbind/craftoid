require 'spec_helper'

###
#   WebCraft 
#     An "abstract base class" 
#     Tested intrinsically by testing its base classes: TwitterCraft, YelpCraft, etc.
#     Behaviour is specified using shared_exampled.
#     See spec/lib/models/shared/web_craft_behaviour.rb
###
describe :WebCraft do
  specify { WebCraft.should_not be_nil }  
end
