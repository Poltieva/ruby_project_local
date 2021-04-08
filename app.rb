require 'socket'
require_relative './classes.rb'

server  = TCPServer.new('localhost', 8080)
SERVER_ROOT = "./views"
repo = Repository.new

loop {
  client = server.accept
  method, path = client.gets.split
  path.chomp!("?")

  headers = {}
  while line = client.gets.split(' ', 2)
    break if line[0] == ""
    headers[line[0].chop] = line[1].strip
  end

  case path
  when "/"
    full_path = SERVER_ROOT + "/index.html"

  when "/users"
    if method == "GET"
      @users = repo.select_users()
      full_path = SERVER_ROOT + '/users.erb'

    elsif method == "POST"
      data = client.read(headers["Content-Length"].to_i)  # Read the POST data as specified in the header
      content = {}
      for pair in data.split("&")
        key, value = pair.split("=")
        content[key] = value
      end
      @new_user = User.new(content["fname"], content["lname"], content["ysalary"].to_i)
      repo.add_user(@new_user.fname, @new_user.lname, @new_user.ysalary)
      full_path = SERVER_ROOT + '/new_user.erb'

    else
      full_path = ''
    end

  when /\/users\/%\d+/
    @user = repo.select_users(path.scan(/\d+/)[0].to_i)
      if @user
        full_path = SERVER_ROOT + '/user.erb'
      else
        full_path = SERVER_ROOT + '/no_user.erb'
      end

  # pseudo delete
  when /\/users\?id=\d+$/
    repo.delete_user(path.scan(/\d+/)[0].to_i)
    @users = repo.select_users()
    full_path = SERVER_ROOT + '/users.erb'

  # pseudo put
  when /\/users\?id=\d+&fname=.*&lname=.*&ysalary=.*$/
    info = path.split("?")[1].split("&")
    id = 0
    command = []
    for el in info
      key, value = el.split("=")
      if key.end_with? "name"
        if value
          command << "#{key} = '#{value}'"
        end
      else
        if key == "id"
          id = value.to_i
        elsif value
          command << "#{key} = #{value}"
        end
      end
    end
    @user = repo.select_users(id)
    if @user
      repo.update_user(id, command.join(", "))
      @users = repo.select_users()
      full_path = SERVER_ROOT + '/users.erb'
    else
      full_path = SERVER_ROOT + '/no_user.erb'
    end


  when /\/users\?sort_by=.+&order=.+$/
    sort_by = path.scan(/(?<=sort_by=).+(?=&)/)[0].to_s
    order = path.scan(/(?<=order=).+(?=$)/)[0].to_s
    @users = repo.select_users(user_id=-1, order_by=sort_by, order=order)
    full_path = SERVER_ROOT + '/users.erb'

  when "/styles.css"
    full_path = SERVER_ROOT + '/styles.css'

  when "/users/styles.css"
    full_path = SERVER_ROOT + '/styles.css'
  else
    full_path = ''
  end

  response = ResponseBuilder.new.respond_with(full_path)

  puts "#{client.peeraddr[3]} #{path} - #{response.code}"
  response.send(client)
  client.close
}
