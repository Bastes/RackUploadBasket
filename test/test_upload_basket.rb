require 'helper'

class TestUploadBasket < Test::Unit::TestCase
  include RackTestCase

  context("(default params)") {
    setup {
      @params = nil
    }
    context("(simple endpoint)") {
      setup {
        @endpoint = lambda { |env|
          [200, {"Content-Type" => "text/html"}, ["Endpoint"]]
        }
      }

      [:get, :post, :put, :delete].each { |verb|
        ['', '/', '/anything', '/anything_else'].each { |path|
          should("let the endpoint handle #{verb} #{path}") {
            send(verb, path)
            assert last_response.ok?
            assert_equal "text/html", last_response.content_type
            assert_equal "Endpoint", last_response.body
          }
        }
      }

      (1..2).each { |number|
        file_path = example_file(number)
        file_name = File.basename(file_path)
        file_size = File.size(file_path)
        file_type = MIME::Types.type_for(file_path).first.content_type
        param_name = example_param_name
        context("on post /upload_basket with example file #{file_name}") {
          setup {
            post "/upload_basket", {},
              post_file_data(param_name, file_path, file_type)
          }
          should("receive the file and send back an overview") {
            assert last_response.ok?
            assert_equal "application/json", last_response.content_type
            assert last_response.body =~
              %r{(['"]?)filename\1: *(['"])#{file_name}\2}
            assert last_response.body =~
              %r{(['"]?)size\1: *#{file_size}\b}
            assert last_response.body =~
              %r{(['"]?)content_type\1: *(['"])#{file_type}\2}
            assert last_response.body =~
              %r{(['"]?)param\1: *(['"])#{param_name}\2}
          }
          should("store the file in the basket directory with its metadata") {
            dir = Rack::UploadBasket::DEFAULT_DIR
            file = File.join(dir, "#{param_name}.file")
            meta = File.join(dir, "#{param_name}.meta")
            data = YAML.load_file(meta)
            assert File.exists?(dir)
            assert File.exists?(file)
            assert File.exists?(meta)
            assert FileUtils.compare_file(file_path, file)
            assert_equal file_name, data[:filename]
            assert_equal file_size, data[:size]
            assert_equal file_type, data[:content_type]
            assert_equal param_name, data[:param]
          }
        }
      }

      context("on post /upload_basket without a file") {
        setup {
          post "/upload_basket", {}, {}
        }
        should("receive the file and send back an overview") {
          assert ! last_response.ok?
          assert_equal 400, last_response.status
        }
      }

      context("on post /upload_basket with something that is not a file") {
        setup {
          post "/upload_basket", {},
            { example_param_name => "anything but a file" }
        }
        should("receive the file and send back an overview") {
          assert ! last_response.ok?
          assert_equal 400, last_response.status
        }
      }
    }
  }
end
