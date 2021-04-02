# TODO add SQL instead of reading a txt file

require 'sinatra'
require_relative './lib/usersclass'

get('/users') do
  erb :index
end

get('/all-users') do
  @users = Array.new
    File.open("C:/Users/polty/Desktop/rub/ruby_site/lib/users.txt", "r") do |file|
      for user in file.readlines()
        info = user.split(" ")
        @user = User.new(info[0], info[1], info[2])
        @users.push(@user)
      end
    end
  erb :all_users
end

post('/save') do
  @user = User.new(param["fname"], param["lname"], param["ysalary"])
end
