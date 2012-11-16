require 'spec_helper'
require 'lib/models/shared/web_craft_behaviour'

describe :TwitterCraft do
  specify { TwitterCraft.should_not be_nil }

  # indicators for this provider
  let (:provider_key)     { '@' }
  let (:provider_symbol)  { :twitter }

  # setup a subject for testing
  let (:subjectClass)       { TwitterCraft }
  let (:subject_id)         { 123 }   # twitter id is an integer
  let (:subject_handle)     { 'xyz' }
  let (:subject_attributes) { {'web_craft_id'=>subject_id, 'username'=>subject_handle} }
  subject                   { TwitterCraft.new subject_attributes }

  it_behaves_like :WebCraft

end