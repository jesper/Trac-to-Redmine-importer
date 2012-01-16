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
      when "select id from ticket order by id desc limit 1;"
        return Mysql::Result.with_row(['123'])
      when "select id,reporter,owner,type,status,component,priority,time,changetime,summary,description from ticket where id=123;"
        return Mysql::Result.with_row(['123','author','assignee','type','status','project/category','priority','time_created','time_modified','subject','description'])
      when "select value from ticket_custom where ticket=123 and name='bugtype'"
        return Mysql::Result.with_row(['bugtype'])
      when "select value from ticket_custom where ticket=123 and name='likelihood'"
        return Mysql::Result.with_row(['likelihood'])
      when "select login from users where id=1"
        return Mysql::Result.with_row(['user'])
      when "select name from issue_categories where id=1"
        return Mysql::Result.with_row(['category'])
      when "select name from enumerations where id=1 and type='IssuePriority'"
        return Mysql::Result.with_row(['priority'])
       else
        return Mysql::Result.with_row(['ERROR'])
     end
  end
end


