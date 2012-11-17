require 'spec_helper'

describe RedisAutoExpire do
  @uniq = 0
  def unique() @uniq = (@uniq||0) + 1 end
  def make_unique_key() "spec:" << Time.now.to_i.to_s << unique.to_s end     # create any key
  def make_unique_value() "value-" << Time.now.to_i.to_s << unique.to_s end  # create any value

  before(:all) do
    @TTL = 1
    @timedREDIS = RedisAutoExpire.new(REDIS, @TTL)
  end
  before(:each) do
    @key = make_unique_key
    @value = make_unique_value
  end
  after(:each) do
    @timedREDIS.del(@key) 
  end

  it :"[]" do
    @timedREDIS[@key].should be_blank
    @timedREDIS[@key] = @value
    @timedREDIS[@key].should eq @value
    @timedREDIS.del(@key)
  end

  it :@keys do
    @timedREDIS[@key].should be_blank
    @timedREDIS.keys.should_not include @key

    @timedREDIS[@key] = @value
    @timedREDIS.keys.should include @key

    @timedREDIS.del(@key)
  end

  it :@del do
    @timedREDIS[@key].should be_blank
    @timedREDIS[@key] = @value
    @timedREDIS[@key].should eq @value
    @timedREDIS.del(@key)
    @timedREDIS[@key].should be_blank
  end

  it :auto_expires do
    @timedREDIS[@key].should be_blank
    @timedREDIS[@key] = @value
    @timedREDIS[@key].should eq @value
    @timedREDIS[@key].should_not be_nil   # key should have a value
    sleep(@TTL + 1)                       # wait for key to expire
    @timedREDIS[@key].should be_nil       # key should now be nil
  end


end