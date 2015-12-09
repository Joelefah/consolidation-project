require 'sinatra'
require 'data_mapper'

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


