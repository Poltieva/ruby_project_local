require 'erb'

class Response
  attr_reader :code

  def initialize(code:, data: "", content_type: nil)
    if content_type
      if code == 201
        @response =
        "HTTP/1.1 #{code}\r\n" +
        "Location: '/users/#{data['id']}'\r\n" +
        "Content-type: #{content_type}\r\n" +
        "Content-Length: #{data.size}\r\n" +
        "\r\n" +
        "#{data}\r\n"
      else
        @response =
        "HTTP/1.1 #{code}\r\n" +
        "Content-type: #{content_type}\r\n" +
        "Content-Length: #{data.size}\r\n" +
        "\r\n" +
        "#{data}\r\n"
      end

    else
      @response =
      "HTTP/1.1 #{code}\r\n" +
      "Content-Length: #{data.size}\r\n" +
      "\r\n" +
      "#{data}\r\n"
    end

    @code = code
  end

  def send(client)
    client.write(@response)
  end
end

class ResponseBuilder

  def respond_with(code, data, content_type)
    if data
      if content_type.include? "text"
        send_ok_response(code, File.binread(data), content_type)
      elsif content_type.include? "json"
        send_ok_response(code, data, content_type)
      else
        send_ok_response(code, data)
      end
    else
      send_file_not_found(code)
    end
  end

  def send_ok_response(code, data, content_type)
    Response.new(code: code, data: data, content_type: content_type)
  end

  def send_file_not_found(code)
    Response.new(code: code)
  end
end
