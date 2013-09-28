require 'spec_helper'
require 'lib/models/shared/web_craft_behaviour'

describe :TwitterCraft do
  subclass_info = {
    clazz: TwitterCraft,
    provider: {
      symbol: :twitter,
      key:    '@'
    },
    subject: {
      id:     123,
      handle: 'my_user_name',
      attributes: {
        name: 'Myfirst Andlast',
        description: 'A great service you can try!'
      }
    }
  }

  it_behaves_like :WebCraft, subclass_info

end