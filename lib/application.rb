require 'sinatra/base'
require 'padrino-helpers'
require 'data_mapper'
require "pry"
require './lib/course'
require './lib/user'

class WorkshopApp < Sinatra::Base
  register Padrino::Helpers
  set :protect_from_csrf, true
  set :admin_logged_in, false
  enable :sessions
  set :session_secret, '112233rlkgrOVNRWOuhsunvwoIE64875644556677' #`or whatever you fancy as a secret.

  env = ENV['RACK_ENV'] || 'development'
    DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/workshop_#{env}")
    DataMapper::Model.raise_on_save_failure = true
    DataMapper.finalize
    DataMapper.auto_upgrade!

  get '/' do
    erb :index
  end

  get '/courses/index' do
    @courses = Course.all
    erb :'courses/index'
   end

   get '/courses/create' do
     erb :'courses/create'
   end

   post '/courses/create' do
     #binding.pry
     Course.create(title: params[:course][:title],description: params[:course][:description])
    redirect 'courses/index'
   end

   get '/users/register' do
    erb :'users/register'

   end

   post '/users/create' do
    begin
      User.create(name: params[:user][:name],
                  email: params[:user][:email],
                  password: params[:user][:password],
                  password_confirmation: params[:user][:password_confirmation])
      session[:flash] = "Your account has been created, #{params[:user][:name]}"
      redirect '/'
    rescue
      session[:flash] = 'Could not register you... Check your input.'
      redirect '/users/register'
    end
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
