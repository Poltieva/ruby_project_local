require 'socket'
require 'json'
require_relative './response_class.rb'
require_relative './request_class.rb'
require_relative './user_class.rb'

server  = TCPServer.new('localhost', 8080)
SERVER_ROOT = "./views"

loop {
  client = server.accept
  request = client.readpartial(2048)

  request = RequestParser.new.parse(request)

  method = request.fetch(:method)
  path = request.fetch(:path)

  if method == "GET" and path == "/"
    code = 200
    data = SERVER_ROOT + "/index.html"
    content_type = "text/html"

  elsif method == "GET" and path == "/users"
    code = 200
    content_type = "application/json"
    if request.fetch(:params)
      sort_by = request[:params].key?(:sort_by) ? request[:params][:sort_by] : 'ysalary'
      order = request[:params].key?(:order) ? request[:params][:order] : 'DESC'
      data = User.select_users(-1, sort_by, order)
    else
      data = User.select_users()
    end

  elsif method == "POST" and path == "/users"
    data = User.add_user(request[:body][:fname], request[:body][:lname], request[:body][:ysalary])
    code = 201
    content_type = 'application/json'
  elsif method == "DELETE" and path =~ /\/users\/\d+/
    id = request[:body][:id].to_i
    data = User.delete_user(id)
    if not data
      code = 404
      content_type = nil
    else
      code = 200
      content_type = "application/json"
    end


  elsif method == "PUT" and path =~ /\/users\/\d+/
    id = request[:body][:id].to_i
    command = []
    request[:body][:fname] == '' ? '' : command << "fname = '" + request[:body][:fname] + "'"
    request[:body][:lname] == '' ? '' : command << "lname = '" + request[:body][:lname] + "'"
    request[:body][:ysalary] == '' ? '' : command << "ysalary = " + request[:body][:ysalary]
    data = User.update_user(id, command.join(", "))
    if data
      code = 200
      content_type = 'application/json'
    else
      code = 404
      content_type = nil
    end

  elsif method == "GET" and path == "/form-for-delete"
    code = 200
    data = SERVER_ROOT + "/delete_form.html"
    content_type = "text/html"

  elsif method == "GET" and path == "/form-for-update"
    code = 200
    data = SERVER_ROOT + "/put_form.html"
    content_type = "text/html"

  elsif method == "GET" and path == "/styles.css"
    code = 200
    data = SERVER_ROOT + "/styles.css"
    content_type = "text/css"

  else
    code = 404
    data = nil
    content_type = nil
  end

  response = ResponseBuilder.new.respond_with(code, data, content_type)

  puts "#{client.peeraddr[3]} #{request.fetch(:path)} - #{response.code}"
  response.send(client)
  client.close
}
