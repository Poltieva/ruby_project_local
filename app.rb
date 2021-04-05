#TODO чистить
require 'socket'
require_relative './lib/classes'

server  = TCPServer.new('localhost', 8080)
repo = Repository.new

loop {
  client = server.accept
  method, path = client.gets.split

  headers = {}
  while line = client.gets.split(' ', 2)
    break if line[0] == ""
    headers[line[0].chop] = line[1].strip
  end
  if path == '/users'
    @users = repo.select_users()
  elsif path.match(/\/user\/\d+/)
    @user = Repository.new.select_users(path.scan(/\d+/)[0].to_i)
  end

  if method == "POST"
    data = client.read(headers["Content-Length"].to_i)  # Read the POST data as specified in the header
    content = {}
    for pair in data.split("&")
      key, value = pair.split("=")
      content[key] = value
    end

    @new_user = User.new(content["fname"], content["lname"], content["ysalary"].to_i)
    repo.add_user(@new_user.fname, @new_user.lname, @new_user.ysalary)
  end

  response = ResponseBuilder.new.prepare(method, path)

  puts "#{client.peeraddr[3]} #{path} - #{response.code}"
  response.send(client)
  client.close
}


# post('/save') do
#   repo.add_user(param["fname"], param["lname"], param["ysalary"])
#   redirect('/all-users')
# end
#



# {:host=>"localhost:8080", :connection=>"keep-alive", :"cache-control"=>"max-age=0", :"sec-ch-ua"=>"\"Google",
# :"sec-ch-ua-mobile"=>"?0", :"upgrade-insecure-requests"=>"1", :"user-agent"=>"Mozilla/5.0",
# :accept=>"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
# :"sec-fetch-site"=>"none", :"sec-fetch-mode"=>"navigate", :"sec-fetch-user"=>"?1", :"sec-fetch-dest"=>"document",
# :"accept-encoding"=>"gzip,", :"accept-language"=>"ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7", :"if-none-match"=>"\"8b-5ae394285ff00\"",
# :"if-modified-since"=>"Tue,"}
