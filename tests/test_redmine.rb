#!/usr/bin/env ruby

require './tests/simplecov.rb'

require 'rubygems'
require 'test/unit'

require './tests/mysql_stub.rb'
require './redmine.rb'

class TestRedmine < Test::Unit::TestCase

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

  def test_find_author
    redmine = Redmine.new('username','password','server','database')
    assert_equal('user',redmine.find_user(1))
  end

  def test_find_invalid_author
    redmine = Redmine.new('username','password','server','database')
    assert_equal('',redmine.find_user(nil))
  end

  def test_find_category
    redmine = Redmine.new('username','password','server','database')
    assert_equal('category',redmine.find_category(1))
  end

  def test_find_invalid_category
    redmine = Redmine.new('username','password','server','database')
    assert_equal('',redmine.find_category(nil))
  end

  def test_find_priority
    redmine = Redmine.new('username','password','server','database')
    assert_equal('priority',redmine.find_priority(1))
  end

  def test_find_invalid_priority
    redmine = Redmine.new('username','password','server','database')
    assert_equal('',redmine.find_priority(nil))
  end
end
