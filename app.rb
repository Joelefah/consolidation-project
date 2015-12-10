require 'sinatra'
require 'data_mapper'
require 'omniauth-twitter'
require 'twitter'

use OmniAuth::Builder do
  provider :twitter, 'kaEWjHXCrRxPHEQxwfddFfYgq', 'lErFeFL0QqqBxZKyibJbgjtUOWSQav9PrmHrBw46GPlkEGPKqE'
end

configure do
  enable :sessions
end

helpers do
  def admin?
    true
  end
end

get '/login' do
  redirect to("/auth/twitter")
  session[:admin]=true
end

get '/logout' do
  session[:admin] = nil
  redirect '/'
end

get '/auth/twitter/callback' do
  env['omniauth.auth'] ? session[:admin] = true : halt(401,'Not Authorized')
  redirect '/'
end

get '/auth/failure' do
  params[:message]
end


DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/todo_list.db")
  
class Item
  include DataMapper::Resource
  property :id        , Serial
  property :name      , Text, :required => true
  property :price     , Integer
  property :weight    , Integer
  property :created   , DateTime
  property :path      , Text
end

DataMapper.finalize.auto_upgrade!

get '/' do
  @items = Item.all(:order => :created.desc)
  redirect '/new' if @items.empty?
  erb :index
end

get '/new' do
  halt(401,'Not Authorized') unless admin?
  erb :form
end

post '/new' do
  @filename = params[:file][:filename]
  file = params[:file][:tempfile]

  Item.create(:name => params[:name], :price => params[:price], :weight => params[:weight], :created => Time.now, :path => @filename)
  @items = Item.all

  File.open("./public/#{@filename}", 'wb') do |f|
    f.write(file.read)
  end

  erb :index
end


