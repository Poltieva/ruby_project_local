require 'sinatra'
require_relative './lib/classes'

repo = Repository.new

get('/users') do
  erb :index
end

get('/all-users') do
  @users = repo.select_users()
  erb :all_users
end

post('/save') do
  repo.add_user(param["fname"], param["lname"], param["ysalary"])
  redirect('/all-users')
end

get('/users/:id') do
  @user = repo.select_users(params['id'].to_i)
  if @user
    erb :user
  else
    erb :no_user
  end
end
