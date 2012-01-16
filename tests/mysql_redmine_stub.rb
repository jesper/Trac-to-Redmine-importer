#!/usr/bin/env ruby

require 'rubygems'
require 'mysql'

class Mysql::Result
  def self.with_row(row)
    @row = row
    return self
  end

  def self.fetch_row
    return @row
  end
end

class Mysql
  def self.real_connect(server,username,password,table)
    return self
  end

  def self.query(query)
    case query
      when "select login from users where id=1"
        return Mysql::Result.with_row(['user'])
      else
        return Mysql::Result.with_row([''])
    end
  end
end


