require 'pg'
require 'json'

class User

    def self.select_users(user_id=-1, order_by='ysalary', order='DESC')
      Repository.select_users(user_id, order_by, order)
    end

    def self.update_user(id, command)
      Repository.update_user(id, command)
    end

    def self.delete_user(id)
      Repository.delete_user(id)
    end

    def self.add_user(fname, lname, ysalary)
      Repository.add_user(fname, lname, ysalary)
    end

end

class Repository

  def self.open_connection
    begin
      @con = PG::Connection.open(:dbname => 'postgres', :user => 'postgres',
        :host => 'localhost', :port => '5432', :password => "Anna546372819!")
    rescue Exception => ex
      puts ex.message
    end
  end

  def self.close_connection
    @con.close if @con
  end

  def self.select_users(user_id=-1, order_by='ysalary', order='DESC')
    # return all users if user_id is not specified
    open_connection
    if user_id == -1
      @results = []

        @con.exec("SELECT * FROM users ORDER BY #{order_by} #{order};").each do |res|
          @results.push res
        end

        return @results.to_json
    else

      begin
        return [@con.exec_params('SELECT * FROM users WHERE id = $1', [user_id])[0]].to_json
      rescue IndexError
        return nil
      end

    end
    self.close_connection
  end

  def self.add_user(fname, lname, ysalary)
    self.open_connection
    @con.exec_params('INSERT INTO users (fname, lname, ysalary) VALUES ( $1, $2, $3 );', [fname, lname, ysalary])
    @user = @con.exec('SELECT * FROM users WHERE id = (SELECT MAX(id) FROM users);')[0].to_json
    self.close_connection
    return @user
  end

  def self.delete_user(id)
    self.open_connection
    begin
      @user = @con.exec_params('SELECT * FROM users WHERE id = $1', [id])[0].to_json
      @con.exec_params('DELETE FROM users WHERE id = $1;', [id])
      self.close_connection
      return @user
    rescue IndexError
      self.close_connection
      return nil
    end
  end

  def self.update_user(id, command)
    self.open_connection
    begin
      @user = @con.exec_params('SELECT * FROM users WHERE id = $1', [id])[0]
      @con.exec_params("UPDATE users SET #{command} WHERE id = #{id};")
      @user = @con.exec_params('SELECT * FROM users WHERE id = $1', [id])[0].to_json
      self.close_connection
      return @user
    rescue IndexError
      self.close_connection
      return nil
    end
  end

end
