#!/usr/bin/env ruby

require 'rubygems'
require './trac.rb'
require './redmine.rb'

trac = Trac.new(ENV['TRAC_USER'], ENV['TRAC_PASSWORD'], ENV['TRAC_HOST'], ENV['TRAC_DATABASE'])
redmine = Redmine.new(ENV['REDMINE_USER'], ENV['REDMINE_PASSWORD'], ENV['REDMINE_HOST'], ENV['REDMINE_DATABASE'])

begin

  latest_trac_ticket = trac.get_latest_ticket()
  puts "Latest Trac ticket is #{latest_trac_ticket.id} with the subject '#{latest_trac_ticket.subject}'"

  latest_redmine_ticket = redmine.get_latest_ticket()
  if latest_redmine_ticket.nil?
    puts "Can't find any Redmine tickets - starting from scratch"
    latest_redmine_ticket = trac.get_earliest_ticket()
  else
    puts "Latest Redmine ticket is #{latest_redmine_ticket}"
  end

  while latest_redmine_ticket <= latest_trac_ticket
    puts "Checking if ticket #{latest_redmine_ticket} exists in Redmine"

    if redmine.has_ticket(latest_redmine_ticket) == false
      puts "Redmine did not have the ticket, creating..."
      redmine.create_ticket(latest_trac_ticket)
    end

#    comments_to_create_in_redmine = get_trac_comments_for_ticket(latest_redmine_ticket) - get_redmine_comments_for_ticket(latest_redmine_ticket)

#    for comment in comments_to_create_in_redmine
#      create_redmine_comment(comment)
#    end

    next_id = latest_redmine_ticket.id + 1
    latest_redmine_ticket = trac.get_ticket_by_id(next_id)

# If the ticket doesn't exist in trac for some reason, keep looking for the next valid ID
    while (latest_redmine_ticket.nil?)
      puts "Skipping #{next_id} since Trac doesn't seem to have any such ticket"
      next_id += 1
      latest_redmine_ticket = trac.get_ticket_by_id(next_id)
    end

  end

rescue Mysql::Error => e
  puts "Error code: #{e.errno}"
  puts "Error message: #{e.error}"
  puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")

ensure
  trac.disconnect
  redmine.disconnect
end

