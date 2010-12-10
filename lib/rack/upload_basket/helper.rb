require 'digest/md5'

module Rack
  class UploadBasket
    module Helper
      def self.hash_key
        Digest::MD5.hexdigest(Time.now.to_s + '-' + rand(1000000000).to_s)
      end
    end
  end
end
