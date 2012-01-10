require 'rubygems'
require 'mysql'
require 'helpers'
require 'ticket'

class Redmine

  def initialize(username, password, server, database)
    @server = Mysql.real_connect(server, username, password, database)
  end

  def get_ticket_by_id(id)
    fields = @server.query("select id,author_id,assigned_to_id,tracker_id,status_id,project_id,category_id,priority_id,created_on,updated_on,subject,description from ticket where id=#{id};").fetch_row
    id = fields[0]
    author = find_user(field[1])
    assignee = find_user(field[2])
    project = convert_trac_component_to_project_and_category(fields[5])[0]
    category = convert_trac_component_to_project_and_category(fields[5])[1]
    bugtype = @server.query("select value from ticket_custom where ticket=#{id} and name='bugtype'").fetch_row[0]
    likelihood = @server.query("select value from ticket_custom where ticket=#{id} and name='likelihood'").fetch_row[0]
    return Ticket.new(fields[0], fields[1], fields[2], fields[3], fields[4], project, category, fields[6], fields[7], fields[8], fields[9], fields[10], likelihood, bugtype)
  end

  def find_user(id)
    return @server.query("select login from users where id=#{id}").fetch_row[0]
  end

  def get_latest_ticket()
    latest_id = @server.query('select id from issues order by id desc limit 1;').fetch_row[0]
    return get_ticket_by_id(latest_id)
  end

end
