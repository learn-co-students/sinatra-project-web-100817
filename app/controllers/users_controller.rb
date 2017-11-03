class UsersController < ApplicationController

  get '/users' do
    erb :"users/index"
  end
  
  get '/users/new' do
    erb :"users/new"
  end

  post '/users' do
    user = User.create(params)
    redirect "/users"
  end

  get '/users/:id' do
    @user = User.find(params[:id])
    erb :"users/show"
  end

  get '/users/:id/edit' do
    @user = User.find(params[:id])
    erb :"users/edit"
  end

  patch '/users/:id' do
    user = User.find(params[:id])
    user.update(name: params[:name])
    redirect "/users/#{user.id}"
  end

  delete '/users/:id' do
    user = User.find(params[:id])
    user.delete
    redirect '/users'
  end

end