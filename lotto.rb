# lotto.rb
# author: Patrick Ziller

require 'sinatra'
require 'sinatra/flash'
require 'tilt/haml'
require 'net/http'

require_relative 'model'
require_relative 'lib/core_ext/object.rb'

THIRTY_MINUTES = 60 * 30
use Rack::Session::Pool, expire_after: THIRTY_MINUTES # Expire sessions after fifteen minutes of inactivity

helpers do
	url = URI.parse('http://www.example.com/index.html')
	req = Net::HTTP::Get.new(url.to_s)
	res = Net::HTTP.start(url.host, url.port) {|http| http.request(req) }
	puts res.body
end


helpers do
  def authenticate!
    unless session[:user]
      session[:original_request] = request.path_info
      redirect '/'
    end
  end
end

before do
  headers 'Content-Type' => 'text/html; charset=utf-8'
end

get '/?' do
  haml :index, locals: { title: "Did you win the powerball?" }
end

post '/login' do
  if user = User.authenticate(params)
    session[:user] = user
    redirect '/home'
  else
    flash[:notice] = 'You could not be signed in. Did you enter the correct username and password?'
    redirect '/'
  end
end

post '/signup' do
  if User.all(email: params[:email]).empty? and User.all(username: params[:username]).empty?
    user = User.new(email: params[:email], username: params[:username].downcase, password: params[:password])
    user.save
    session[:user] = user[:id]
    redirect '/home'
  else
    flash[:notice] = 'Sorry, that username or email is already taken.'
    redirect '/'
  end
end

get '/home/?*' do
  authenticate!
  haml :home, locals: { title: "Add or view your tickets" }
end

post '/home/add-lotto-ticket' do
  User.first(id: session[:user]).lotto_tickets.new(num1: params[:num1],
                                                   num2: params[:num2],
                                                   num3: params[:num3],
                                                   num4: params[:num4],
                                                   num5: params[:num5],
                                                   num6: params[:num6]).save
  redirect '/home'
end

get '/signout' do
  session[:user] = nil
  flash[:notice] = 'You have been signed out.'
  redirect '/'
end
