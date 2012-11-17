require 'spec_helper'
require 'lib/models/shared/web_craft_behaviour'

describe :FacebookCraft do
  subclass_info = {
    clazz: FacebookCraft,
    provider: {
      symbol: :facebook,
      key:    'fb'
    },
    subject: {
      id:     123,
      handle: '123',
      attributes: {
        name: 'Myfirst Andlast',
        description: 'A great service you can try!'
      }
    }
  }

  it_behaves_like :WebCraft, subclass_info

end
