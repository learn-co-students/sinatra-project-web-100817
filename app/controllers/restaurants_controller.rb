class RestaurantsController < ApplicationController

  get '/restaurants' do
    erb :"restaurants/index"
  end
  
  get '/restaurants/new' do
    erb :"restaurants/new"
  end

  post '/restaurants' do
    restaurant = Restaurant.create(params)
    redirect "/restaurants"
  end

  get '/restaurants/:id' do
    @restaurant = Restaurant.find(params[:id])
    erb :"restaurants/show"
  end

  get '/restaurants/:id/edit' do
    @restaurant = Restaurant.find(params[:id])
    erb :"restaurants/edit"
  end

  patch '/restaurants/:id' do
    restaurant = Restaurant.find(params[:id])
    # binding.pry
    restaurant.update(name: params[:name]) if params[:name] && params[:name] != ""
    restaurant.update(rating: params[:rating]) if params[:rating]
    restaurant.update(address: params[:address]) if params[:address] &&params[:address] != ""
    if params[:remove_users] && !params[:remove_users].empty?
      params[:remove_users].each do |user_id|
        restaurant.users.delete(User.find(user_id))
      end
    end
    restaurant.users << User.find(params[:add_customer]) if params[:add_customer] && params[:add_customer] != ""
    redirect "/restaurants/#{restaurant.id}"
  end

  delete '/restaurants/:id' do
    restaurant = Restaurant.find(params[:id])
    restaurant.delete
    redirect '/restaurants'
  end

  post '/yelp_lookup' do
    results = YelpApi.search(params[:item], params[:location])["businesses"]
    results.each do |r|
      Restaurant.create(name: r["name"], rating: r["rating"], address: r["location"]["address1"])
    end
    redirect '/restaurants'
  end

end