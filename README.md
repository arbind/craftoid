# Craftoid

Domain model objects and search service for an organization's craft and their (embedded) webcrafts.

    requires a mongoDB server for saving models
    requires a redis server for geo caching

## Installation

Create your application without ORM:

    $ rails new crafty_app -T -J -O
    # -O excludes ActiveRecord ORM becuase the gem use Mongoid
    # -T excludes the Test/Unit (use rspec instead)
    # -J excludes the prototype.js (use jQuery instead)


Add this line to your application's Gemfile:

    gem 'craftoid', :git => 'git@github.com:arbind/craftoid.git'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install craftoid (once and if it is published)

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
