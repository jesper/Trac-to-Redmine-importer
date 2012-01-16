require 'rubygems'
require 'mysql'
require './ticket.rb'

class Redmine

  def initialize(username, password, server, database)
    @server = Mysql.real_connect(server, username, password, database)
  end

  def get_ticket_by_id(id)
    fields = @server.query("select id,author_id,assigned_to_id,tracker_id,status_id,project_id,category_id,priority_id,created_on,updated_on,subject,description from ticket where id=#{id};").fetch_row

    id = fields[0]
    author = find_user(field[1])
    assignee = find_user(field[2])
    type = find_type(field[3])
    status = find_status(field[4])
    project = find_project(field[5])
    category = find_category(field[6])
    priority = find_priority(field[6])
    time_created = field[7]
    time_modified = field[8]
    subject = field[9]
    description = field[10]
    likelihood = find_likelihood(field[11])
    bugtype = find_bugtype(field[12])

    return Ticket.new(id, author, assignee, type, status, project, category, priority, time_created, time_modified, subject, description, likelihood, bugtype)
  end

  def find_likelihood_id
    return @server.query("select id from custom_fields where name='Likelihood';").fetch_row[0]
  end

  def find_bug_type_id
    return @server.query("select id from custom_fields where name='Bug-Type';").fetch_row[0]
  end

  def find_likelihood(id)
    return @server.query("select value from custom_values where customized_id=#{id} and custom_field_id=#{find_likelihood_id};").fetch_row[0]
  end

  def find_bugtype(id)
    return @server.query("select value from custom_values where customized_id=#{id} and custom_field_id=#{find_bug_type_id};").fetch_row[0]
  end

  def find_user(id)
    return @server.query("select login from users where id=#{id}").fetch_row[0]
  end

  def find_priority(id)
    return @server.query("select name from enumerations where id=#{id} and type='IssuePriority'").fetch_row[0]
  end

  def find_issue_type(id)
    return @server.query("select name from trackers where id=#{id}").fetch_row[0]
  end

  def find_status(id)
    return @server.query("select name from issue_statuses where id=#{id}").fetch_row[0]
  end

  def find_category(id)
    return @server.query("select name from issue_categories where id=#{id}").fetch_row[0]
  end

  def find_project(id)
    return @server.query("select name from projects where id=#{id}").fetch_row[0]
  end

  def get_latest_ticket()
    latest_id = @server.query('select id from issues order by id desc limit 1;').fetch_row[0]
    return get_ticket_by_id(latest_id)
  end

  def create_ticket(ticket)
   puts 'tbd'
  end

  def create_comment(comment)
    puts 'tbd'
  end

  def has_ticket(ticket)
    puts 'tbd'
  end

  def get_comments_for_ticket(ticket)
    puts 'tbd'
  end

  def disconnect
    @server.close
  end

end
