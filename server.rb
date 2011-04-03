require 'rubygems'
require 'sinatra'

# Setup the public dir as root dir, this then just acts as a file server.
set :public, File.dirname(__FILE__)
set :port, 9495

#
# Setup some mime types
mime_type :ejs, "text/html"

get '/' do
  return File.read('index.html')
end

puts "Hit the URL http://localhost:9495"
