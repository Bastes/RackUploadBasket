require 'helper'

class TestUploadBasketHelper < Test::Unit::TestCase
  should("provide a lot of different upload hash keys in a very short time") {
    keys = (0..999).map {
      Rack::UploadBasket::Helper.hash_key
    }.uniq
    assert_equal 1000, keys.length
  }
end
