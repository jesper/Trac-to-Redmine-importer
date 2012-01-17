#!/usr/bin/env ruby

require './tests/simplecov.rb'

require 'rubygems'
require 'test/unit'

require './tests/mysql_stub.rb'
require './trac.rb'

class TestTrac < Test::Unit::TestCase

  def verify_ticket(ticket)
    assert_equal(123, ticket.id)
    assert_equal('version', ticket.version)
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

  def test_get_ticket_by_id
    trac = Trac.new('username','password','server','database')
    verify_ticket(trac.get_ticket_by_id(123))
  end

  def test_get_latest_ticket
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

end
