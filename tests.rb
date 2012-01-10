#!/usr/bin/env ruby

require 'rubygems'
require 'test/unit'
require 'mysql'
require 'trac'
require 'redmine'
require 'helpers'

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
     end
  end
end


class TestImporter < Test::Unit::TestCase

  def verify_ticket(ticket)
    assert_equal('123', ticket.id)
    assert_equal('author', ticket.author)
    assert_equal('assignee', ticket.assignee)
    assert_equal('type', ticket.type)
    assert_equal('status', ticket.status)
    assert_equal('project', ticket.project)
    assert_equal('category', ticket.category)
    assert_equal('priority', ticket.priority)
    assert_equal('time_created', ticket.time_created)
    assert_equal('time_modified', ticket.time_modified)
    assert_equal('subject', ticket.subject)
    assert_equal('description', ticket.description)
    assert_equal('bugtype', ticket.bugtype)
    assert_equal('likelihood', ticket.likelihood)
  end

  def test_trac_get_ticket_by_id
    trac = Trac.new('username','password','server','database')
    verify_ticket(trac.get_ticket_by_id(123))
  end

  def test_trac_get_latest_ticket
    trac = Trac.new('username','password','server','database')
    verify_ticket(trac.get_latest_ticket)
  end

  def test_convert_component_to_project_and_category
    trac = Trac.new('username','password','server','database')
    assert_equal(['project',''], trac.convert_component_to_project_and_category('project'))
    assert_equal(['project', 'component'], trac.convert_component_to_project_and_category('project/component'))
    assert_equal(['project', 'component-with-hyphens'], trac.convert_component_to_project_and_category('project/component-with-hyphens'))
    assert_equal(['project', 'component-with-funky_characters () & *'], trac.convert_component_to_project_and_category('project/component-with-funky_characters () & *'))
  end

  def test_redmine_find_author
    redmine = Redmine.new('username','password','server','database')
    assert_equal('user',redmine.find_user(1))
  end
end
