require 'spec_helper'
require 'lib/models/shared/web_craft_behaviour'

describe :YelpCraft do
  subclass_info = {
    clazz: YelpCraft,
    provider: {
      symbol: :yelp,
      key:    'yelp'
    },
    subject: {
      id:     'a-yelp-id',
      handle: 'a-yelp-id',
      attributes: {
        name: 'Myfirst Andlast',
        description: 'A great service that is just around the corner from you!'
      }
    }
  }

  it_behaves_like :WebCraft, subclass_info

end
