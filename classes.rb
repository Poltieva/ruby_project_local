require 'pg'
require 'erb'

class User
  attr_accessor :fname, :lname, :ysalary
  def initialize(fname, lname, ysalary)
    @fname = fname
    @lname = lname
    @ysalary = ysalary
  end
end

class Repository

  def open_connection
    begin
      @con = PG::Connection.open(:dbname => 'postgres', :user => 'postgres',
        :host => 'localhost', :port => '5432', :password => "Anna546372819!")
    rescue Exception => ex
      puts e.message
    end
  end

  def close_connection
    @con.close if @con
  end

  def select_users(user_id=-1, order_by='ysalary', order='DESC')
    # return all users if user_id is not specified
    open_connection
    if user_id == -1
      @results = []

        @con.exec("SELECT * FROM users ORDER BY #{order_by} #{order};").each do |res|
          @results.push res
        end

        return @results
    else

      begin
        return @con.exec_params('SELECT * FROM users WHERE id = $1', [user_id])[0]
      rescue IndexError
        return nil
      end

    end
    close_connection
  end

  def add_user(fname, lname, ysalary)
    open_connection
    @con.exec_params('INSERT INTO users (fname, lname, ysalary) VALUES ( $1, $2, $3 );', [fname, lname, ysalary])
    close_connection
  end

  def delete_user(id)
    open_connection
    @con.exec_params('DELETE FROM users WHERE id = $1;', [id])
    close_connection
  end

  def update_user(id, command)
    open_connection
    @con.exec("UPDATE users SET #{command} WHERE id = #{id};")
    close_connection
  end

end



class Response
  attr_reader :code

  def initialize(code:, data: "")
    @response =
    "HTTP/1.1 #{code}\r\n" +
    "Content-Length: #{data.size}\r\n" +
    "\r\n" +
    "#{data}\r\n"

    @code = code
  end

  def send(client)
    client.write(@response)
  end
end

class ResponseBuilder

  def respond_with(path)
    if path != ''
      send_ok_response(File.binread(path))
    else
      send_file_not_found
    end
  end

  def send_ok_response(data)
    Response.new(code: 200, data: ERB.new(data).result)
  end

  def send_file_not_found
    Response.new(code: 404)
  end
end