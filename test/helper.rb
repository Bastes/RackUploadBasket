require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rack/test'
require 'test/unit'
require 'shoulda'
require 'mime/types'

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.dirname(__FILE__))
require 'rack/upload_basket'

class Test::Unit::TestCase
  def post_file_data(param_name, file_path, content_type)
    file_name = File.basename(file_path)
    boundary = "AaB03x"
    data = "--#{boundary}\r\n" +
           "Content-Disposition: form-data; name=\"#{param_name}\"; " +
             "filename=\"#{file_name}\"\r\n" +
           "Content-Type: #{content_type}\r\n" +
           "\r\n" +
           "#{File.read(file_path)}\r\n" +
           "--#{boundary}--\r\n" +
           "\r\n"
    { "CONTENT_TYPE" => "multipart/form-data, boundary=\"#{boundary}\"",
      "CONTENT_LENGTH" => data.length, :input => data }
  end

  def self.example_file(number)
    @_detection ||= %r{\Aexample_file_([0-9]+)\.\w+\Z}
    @_resources ||= File.join(File.dirname(__FILE__), "resources")
    @_files ||= Hash[*(Dir.open(@_resources).
                           grep(@_detection).
                           map { |f| [f[@_detection, 1].to_i, f] }.
                           flatten)]
    File.join(@_resources, @_files[number])
  end
end
