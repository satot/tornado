# web.rb
require 'sinatra'
require 'sinatra/reloader' if development?
require 'erb'
require 'oauth'

# 登録済みのconsumer_keyとconsumer_secretに置き換える必要がある。
# consumer_keyとconsumer_secretはサイトの「環境」ページ参照。
KEY = "$KEY"
SECRET = "$SECRET"

configure do
  set :sessions, true
  enable :sessions
  use Rack::Session::Cookie, :secret => SecureRandom.hex(32)
end

helpers do
  def oauth_consumer
    OAuth::Consumer.new(KEY, SECRET, :site => "http://twitter.com")
  end
end


get '/' do
  if session[:access_token]
    erb :index
  else
    redirect '/login'
  end
end

get '/login' do
  erb :login
end

get '/logout' do
  session.clear
  redirect '/login'
end

get '/auth' do
  callback_url = "http://localhost:4567/auth_success"
  request_token = oauth_consumer.get_request_token(:oauth_callback => callback_url)
  session[:request_token] = request_token.token
  session[:request_token_secret] = request_token.secret
  redirect request_token.authorize_url
end

get '/auth_success' do
  request_token = OAuth::RequestToken.new(oauth_consumer, session[:request_token], session[:request_token_secret])
  begin
    @access_token = request_token.get_access_token(
      {},
      :oauth_token => params[:oauth_token],
      :oauth_verifier => params[:oauth_verifier])
  rescue OAuth::Unauthorized => @exception
    puts(@exception.message)
    return erb %{ oauth failed }
  end

  session[:access_token] = @access_token.token
  session[:access_token_secret] = @access_token.secret

  redirect '/'
end

## static file contents
get '/favicon.ico' do
  send_file "static/favicon.ico"
end

use Rack::Static, :urls => ["/images"], :root => "static"
use Rack::Static, :urls => ["/js"], :root => "static"
use Rack::Static, :urls => ["/css"], :root => "static"

