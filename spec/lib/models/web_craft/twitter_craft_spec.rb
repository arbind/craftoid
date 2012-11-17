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


  ##
  #   Check materializing with an integer id
  ##
  it :@@materialize_works_with_integer_id do
    id = subclass_info[:subject][:id]
    wc = TwitterCraft.materialize({web_craft_id: id.to_i})
    wc.should_not be_nil
    wc.web_craft_id.should eq id.to_s
  end

end