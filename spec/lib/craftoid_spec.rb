require 'spec_helper'

describe :gem do
  specify { Craftoid.should_not be_nil }

  context :DB_uses_test_environment do

    # don't let tests overwrite data in dev or production!
    it :ping_redis do
      REDIS.ping.should include 'PONG'
    end

    it :ping_mongoid do
      Mongoid.database.command({ping: 1}).should include 'ok'
    end
  end

end
