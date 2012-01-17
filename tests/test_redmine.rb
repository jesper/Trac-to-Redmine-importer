#!/usr/bin/env ruby

require './tests/simplecov.rb'

require 'rubygems'
require 'test/unit'

require './tests/mysql_stub.rb'
require './redmine.rb'

class TestRedmine < Test::Unit::TestCase

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
