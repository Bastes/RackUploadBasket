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
        upload = request.params["upload_basket"]
        [200, {"Content-Type" => "application/json"}, [{
          :filename => upload[:filename],
          :size => ::File.size(upload[:tempfile]),
          :content_type => upload[:type]
        }.to_json]]
      else
        @next_on_line.call(env)
      end
    end
  end
end
