require 'spec_helper'

describe :gem do
  it { Craftoid.should_not be_nil }
  it { Craft.should_not be_nil }
  it { WebCraft.should_not be_nil }
  it { TwitterCraft.should_not be_nil }
  it { YelpCraft.should_not be_nil }
  it { WebsiteCraft.should_not be_nil }
end