require 'rubygems'
require 'mysql'

require './ticket.rb'

class Trac

  def initialize(username, password, server, database)
    @server = Mysql.real_connect(server, username, password, database)
  end

  def get_ticket_by_id(id)
    fields = @server.query("select id,reporter,owner,type,status,component,priority,time,changetime,summary,description from ticket where id=#{id};").fetch_row

    return nil if fields.nil?

    project = convert_component_to_project_and_category(fields[5])[0]
    category = convert_component_to_project_and_category(fields[5])[1]
    bugtype = get_bug_type(id)
    likelihood = get_likelihood(id)
    return Ticket.new(fields[0], fields[1], fields[2], fields[3], fields[4], project, category, fields[6], fields[7], fields[8], fields[9], fields[10], likelihood, bugtype)
  end

  def get_bug_type(id)
    bug_type = @server.query("select value from ticket_custom where ticket=#{id} and name='bugtype'").fetch_row
    return '' if bug_type.nil?
    return bug_type[0]
  end

  def get_likelihood(id)
    likelihood = @server.query("select value from ticket_custom where ticket=#{id} and name='likelihood'").fetch_row
    return '' if likelihood.nil?
    return likelihood[0]
  end

  def get_latest_ticket()
    latest_id = @server.query('select id from ticket order by id desc limit 1;').fetch_row[0]
    return get_ticket_by_id(latest_id)
  end

  def get_earliest_ticket()
    earliest_id = @server.query('select id from ticket order by id asc limit 1;').fetch_row[0]
    return get_ticket_by_id(earliest_id)
  end


  def convert_component_to_project_and_category(component)
    values = component.split('/', 2)
    if (values.length == 1)
      return values+['']
    else
      return values
    end
  end

  def get_comments_for_ticket(ticket)
    puts 'tbd'
  end

  def disconnect
    @server.close
  end
end
