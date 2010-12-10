require 'rack'
require 'json'
require 'fileutils'
require 'rack/upload_basket/helper'

module Rack
  class UploadBasket
    def initialize(next_on_line, options)
      @next_on_line = next_on_line
    end

    def call(env)
      request = Rack::Request.new(env)
      if request.path == "/upload_basket" && request.post?
        begin
          param_key = request.params.keys.grep(%r{\Aupload_basket_[a-z0-9]+\Z}).
            first
          upload = request.params[param_key]
          [200, {"Content-Type" => "application/json"}, [{
            :filename => upload[:filename],
            :size => ::File.size(upload[:tempfile]),
            :content_type => upload[:type],
            :param => param_key
          }.to_json]]
        rescue
          [400, {"Content-Type" => "text/plain"}, [""]]
        end
      else
        @next_on_line.call(env)
      end
    end
  end
end
