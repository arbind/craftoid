# Craftoid

Domain model objects for an organization's craft and their (embedded) webcrafts.

    uses a mongoDB server for saving models
    uses a redis server for geo caching

## Installation

Create your application without ORM:

    $ rails new crafty_app -T -J -O
    # -O excludes ActiveRecord ORM becuase the gem use Mongoid
    # -T excludes the Test/Unit (use rspec instead)
    # -J excludes the prototype.js (use jQuery instead)

Add these dependencies (appropriately) to your Gemfile:

    gem 'redis'         , '~>3.0.4'
    gem 'geocoder'      , '~>1.1.8'
    gem 'mongoid'       , github: 'mongoid/mongoid', ref: '3b1ada6' # 4.0.0(master)
    gem 'craftoid'      , github: 'arbind/craftoid', ref: 'b21f06c73c'

And then execute:

    $ bundle


Add an empty Craft model in app/models/craft.rb with:

    class Craft
    end

Opening the Craft class brings in awareness of the class for rake.


Now create the geo-spacial indexes:

    rake db:mongoid:create_indexes


Create mongoid config file (otherwise craftoid db will be used to store crafts):

    rails generate mongoid:config

Configure the goecoder gem in geocoder_cfg.rb

    require 'geocoder' # configure geocoder to use redis:

    GEOCODER_CACHE_TTL = 86400 # (60s * 60m * 24h)  # +++ TODO move TTL for geo cache into configs

    geocoder_config = {
      lookup: :google,
      cache: RedisAutoExpire.new(REDIS, GEOCODER_CACHE_TTL),
      cache_prefix: "gO:" # gee-oooh :)
    }

    Geocoder.configure geocoder_config


## Usage

Start the console for your application:

    $ rails c
    1.9.3 > t = TwitterCraft.new
    1.9.3 > c = Craft.new
    1.9.3 > c.bind t
    1.9.3 > c.save!

## Testing

The default rake task will run rspec and coverage test:

    rake spec
    open coverage/index.html

## Capabilities

1. Create new Crafts, bind their corresponding WebCrafts (website, twitter, yelp, facebook, etc.)
2. Search for Crafts

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## To Build this gem locally:
    $ gem uninstall craftoid
    $ rake install

## References

1. ref: [http://rakeroutes.com/blog/lets-write-a-gem-part-two/](http://rakeroutes.com/blog/lets-write-a-gem-part-two/)
2. ref: [http://railscasts.com/episodes/245-new-gem-with-bundler](http://railscasts.com/episodes/245-new-gem-with-bundler)


Example mongoid.yml file:

    development:
      host: localhost
      database: craft_service_development

    test:
      host: localhost
      database: craft_service_test

    # set these environment variables on your prod server
    production:
      host: <%= ENV['MONGOID_HOST'] %>
      port: <%= ENV['MONGOID_PORT'] %>
      username: <%= ENV['MONGOID_USERNAME'] %>
      password: <%= ENV['MONGOID_PASSWORD'] %>
      database: <%= ENV['MONGOID_DATABASE'] %>
      # slaves:
      #   - host: slave1.local
      #     port: 27018
      #   - host: slave2.local
      #     port: 27019
