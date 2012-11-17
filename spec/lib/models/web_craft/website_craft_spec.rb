require 'spec_helper'
require 'lib/models/shared/web_craft_behaviour'

describe :WebsiteCraft do
  subclass_info = {
    clazz: WebsiteCraft,
    provider: {
      symbol: :website,
      key:    'website'
    },
    subject: {
      id:     'http://the-website-address.com',
      handle: 'http://the-website-address.com',
      attributes: {
        name: 'Myfirst Andlast',
        description: 'A great service you can try!'
      }
    }
  }

  it_behaves_like :WebCraft, subclass_info

end
