require 'spec_helper'

describe :@urlify_string_extention do
  context :given_nil do
    it :@urlify do
      href = nil
      href.urlify!
      href.should eq nil
    end

    it :@looks_like_url do
      nil.looks_like_url?.should eq false
    end

  end

  context :given_a_string_that_is_not_a_url do

    it :@looks_like_url_is_false do
      "".looks_like_url?.should eq false
      "no.way.jose".looks_like_url?.should eq false
      "call me maybe".looks_like_url?.should eq false
      "http fox".looks_like_url?.should eq false
      "I aint a website address".looks_like_url?.should eq false
      "ww".looks_like_url?.should eq false
      "www".looks_like_url?.should eq false
      # "http://fox".looks_like_url?.should eq false  # +++ TODO enable this test
    end

    it :@urlify_wont_change_the_string do
      href = not_a_web_site = "I aint a website address" 
      href.urlify!
      href.should eq not_a_web_site
    end

    it :@provider_is_nil do
      "".provider.should be_nil
      "no.way.jose".provider.should be_nil
      "call me maybe".provider.should be_nil
      "http fox".provider.should be_nil
      "I aint a website address".provider.should be_nil
      "ww".provider.should be_nil
      "www".provider.should be_nil
    end

  end

  context :given_a_string_that_is_a_url do

    it :@looks_like_url_is_true do
      "yelp.com".looks_like_url?.should eq true
      "//yelp.com".looks_like_url?.should eq true
      "http://yelp.com".looks_like_url?.should eq true
      "https://yelp.com".looks_like_url?.should eq true
      "www.yelp.com".looks_like_url?.should eq true
      "//www.yelp.com".looks_like_url?.should eq true
      "http://www.yelp.com".looks_like_url?.should eq true
      "https://www.yelp.com".looks_like_url?.should eq true
    end

    it :@urlify_will_modify_the_string_into_url_form do
      "yelp.com".urlify!.should eq "http://yelp.com"
      "//yelp.com".urlify!.should eq "http://yelp.com"
      "www.yelp.com".urlify!.should eq "http://www.yelp.com"
      "//www.yelp.com".urlify!.should eq "http://www.yelp.com"
    end

    it :@urlify_will_preserve_a_string_already_in_url_form do
      href = url = "http://yelp.com"
      href.urlify!.should eq url
      
      href = url = "https://yelp.com"
      href.urlify!.should eq url
      
      href = url = "http://www.yelp.com"
      href.urlify!.should eq url
      
      href = url = "https://www.yelp.com"
      href.urlify!.should eq url
    end

    it :@provider do
      # naked
      "yelp.com".provider.should eq :yelp
      "twitter.com".provider.should eq :twitter
      "facebook.com".provider.should eq :facebook
      # www
      "www.yelp.com".provider.should eq :yelp
      "www.twitter.com".provider.should eq :twitter
      "www.facebook.com".provider.should eq :facebook
      # naked and default protocol
      "//yelp.com".provider.should eq :yelp
      "//twitter.com".provider.should eq :twitter
      "//facebook.com".provider.should eq :facebook
      # www and default protocol
      "//www.yelp.com".provider.should eq :yelp
      "//www.twitter.com".provider.should eq :twitter
      "//www.facebook.com".provider.should eq :facebook
      # naked and http
      "http://yelp.com".provider.should eq :yelp
      "http://twitter.com".provider.should eq :twitter
      "http://facebook.com".provider.should eq :facebook
      # www and http
      "http://www.yelp.com".provider.should eq :yelp
      "http://www.twitter.com".provider.should eq :twitter
      "http://www.facebook.com".provider.should eq :facebook
      # naked and https
      "https://yelp.com".provider.should eq :yelp
      "https://twitter.com".provider.should eq :twitter
      "https://facebook.com".provider.should eq :facebook
      # www and https
      "https://www.yelp.com".provider.should eq :yelp
      "https://www.twitter.com".provider.should eq :twitter
      "https://www.facebook.com".provider.should eq :facebook

      #naked
      "my-site.com".provider.should eq :website
      "//my-site.com".provider.should eq :website
      "http://my-site.com".provider.should eq :website
      "https://my-site.com".provider.should eq :website
      # www
      "www.my-site.com".provider.should eq :website
      "//www.my-site.com".provider.should eq :website
      "http://www.my-site.com".provider.should eq :website
      "https://www.my-site.com".provider.should eq :website
    end

  end

end