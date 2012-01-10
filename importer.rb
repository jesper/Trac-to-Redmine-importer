#!/usr/bin/env ruby

require 'rubygems'
require 'trac'
require 'helpers.rb'



trac = Trac.new(ENV['TRAC_USER'], ENV['TRAC_PASSWORD'], ENV['TRAC_HOST'], ENV['TRAC_DATABASE'])

begin

  latest_trac_ticket = trac.get_latest_ticket()
#  latest_redmine_ticket = get_latest_redmine_ticket()

#  while latest_redmine_ticket <= latest_trac_ticket
#    if redmine_has_ticket(latest_redmine_ticket) == false
#      create_redmine_ticket(latest_trac_ticket)
#    end

#    comments_to_create_in_redmine = get_trac_comments_for_ticket(latest_redmine_ticket) - get_redmine_comments_for_ticket(latest_redmine_ticket)

#    for comment in comments_to_create_in_redmine
#      create_redmine_comment(comment)
#    end

#    latest_redmine_ticket = get_trac_ticket_by_id(latest_redmine_ticket.id)
#  end

rescue Mysql::Error => e
  puts "Error code: #{e.errno}"
  puts "Error message: #{e.error}"
  puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")

ensure
  trac.disconnect
end

