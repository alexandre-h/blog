require 'sinatra'
require 'sinatra/reloader' if development?
require_relative 'database'

configure do
  set :database, DB
  set :comments, COMMENTS
  set :posts, settings.database.zip(settings.comments)
end

get '/' do
  @posts = settings.posts.last(2).reverse
  erb :index
end

get '/articles' do
  @posts = settings.posts.reverse
  erb :articles
end

get '/articles/:sorted' do
  settings.database.each_with_index { |post, i| post[:index] = i + 1 }
  posts = settings.database.zip(settings.comments)
  case params[:sorted]
  when 'stars'
    sorted_posts = posts.sort_by { |k| k[0][:rating].to_i }
  when 'comments'
    sorted_posts = posts.sort_by { |k| k[1].count }
  end
  @posts = sorted_posts.reverse
  erb :articles
end

get '/article/:id' do
  settings.database.each_with_index { |post, i| post[:index] = i + 1 }
  posts = settings.database.zip(settings.comments)
  @post = posts.select { |item| item[0][:index].to_i == params[:id].to_i }
  erb :article
end

get '/contact' do
  erb :contact
end

post '/search' do
  @search = params[:search]
  posts = settings.posts.reverse
  @posts = posts.select { |item| item[0][:title].include? @search }
  erb :search
end
