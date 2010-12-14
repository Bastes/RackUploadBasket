require 'rack'
require 'json'
require 'fileutils'
require 'rack/upload_basket/helper'
require 'tmpdir'
require 'yaml'

module Rack
  class UploadBasket
    DEFAULT_DIR = ::File.join(Dir.tmpdir, 'upload_basket')

    def initialize(next_on_line, options)
      @next_on_line = next_on_line
      create_directory
    end

    def create_directory
      if ::File.exists?(directory)
        unless ::File.directory?(directory)
          raise "#{directory} exists and is not a directory"
        end
      else
        FileUtils.mkdir_p directory
      end
    end

    def directory
      DEFAULT_DIR
    end

    def call(env)
      request = Rack::Request.new(env)
      if request.path == "/upload_basket" && request.post?
        begin
          param_key = request.params.keys.grep(%r{\Aupload_basket_[a-z0-9]+\Z}).
            first
          upload = request.params[param_key]
          meta = { :filename => upload[:filename],
                   :size => ::File.size(upload[:tempfile]),
                   :content_type => upload[:type],
                   :param => param_key }
          store_path = ::File.join(directory, "#{param_key}.file")
          meta_path = ::File.join(directory, "#{param_key}.meta")
          FileUtils.mv upload[:tempfile].path, store_path
          ::File.open(meta_path, 'w') { |f| f << YAML.dump(meta) }
          [200, {"Content-Type" => "application/json"}, [meta.to_json]]
        rescue
          [400, {"Content-Type" => "text/plain"}, [""]]
        end
      else
        @next_on_line.call(env)
      end
    end
  end
end
