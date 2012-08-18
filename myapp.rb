# myapp.rb
require 'sinatra'
require 'sinatra/reloader' if development?

require 'erb'


get '/' do
  erb :index
end




## static file contents
get '/favicon.ico' do
  send_file "static/favicon.ico"
end

use Rack::Static, :urls => ["/images"], :root => "static"
use Rack::Static, :urls => ["/js"], :root => "static"
use Rack::Static, :urls => ["/css"], :root => "static"
