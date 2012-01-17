require 'rubygems'
require 'mysql'

require './ticket.rb'
require './comment.rb'

class Redmine

  def initialize(username, password, server, database)
    @server = Mysql.real_connect(server, username, password, database)
  end

  def get_ticket_by_id(id)
    fields = @server.query("select id,author_id,assigned_to_id,tracker_id,status_id,project_id,category_id,priority_id,created_on,updated_on,subject,description,fixed_version_id from issues where id=#{id};").fetch_row

    id = fields[0]
    author = find_user(fields[1])
    assignee = find_user(fields[2])
    type = find_issue_type(fields[3])
    status = find_status(fields[4])
    project = find_project(fields[5])
    category = find_category(fields[6])
    priority = find_priority(fields[7])
    time_created = fields[8]
    time_modified = fields[9]
    subject = fields[10]
    description = fields[11]
    version = find_version(fields[12])
    likelihood = find_likelihood(id)
    bugtype = find_bugtype(id)

    return Ticket.new(id, version, author, assignee, type, status, project, category, priority, time_created, time_modified, subject, description, likelihood, bugtype)
  end

  def find_version(id)
    return @server.query("select name from versions where id=#{id};").fetch_row[0]
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
    return '' if id.nil?
    return @server.query("select login from users where id=#{id}").fetch_row[0]
  end

  def find_priority(id)
    return '' if id.nil?
    return @server.query("select name from enumerations where id=#{id} and type='IssuePriority'").fetch_row[0]
  end

  def find_issue_type(id)
    return @server.query("select name from trackers where id=#{id}").fetch_row[0]
  end

  def find_status(id)
    return @server.query("select name from issue_statuses where id=#{id}").fetch_row[0]
  end

  def find_category(id)
    return '' if id.nil?
    return @server.query("select name from issue_categories where id=#{id}").fetch_row[0]
  end

  def find_project(id)
    return @server.query("select name from projects where id=#{id}").fetch_row[0]
  end

  def get_latest_ticket()
    latest_id = @server.query('select id from issues order by id desc limit 1;').fetch_row

    return nil if latest_id.nil?
    return get_ticket_by_id(latest_id[0])
  end

  def create_ticket(ticket)
   puts "TBD: Redmine::create_ticket(#{ticket})"
   id = ticket.id
   tracker_id = find_tracker_id(ticket.type)
   project_id = find_project_id(ticket.project)
   subject = ticket.subject
   description = ticket.description
   due_date = nil
   category_id = find_category_id(ticket.category)
   status_id = find_status_id(ticket.status)
   assigned_to_id = find_user_id(ticket.assignee)
   priority_id = find_priority_id(ticket.priority)
   fixed_version_id = find_version_id(ticket.version)
   author_id = find_user_id(ticket.author)
   lock_version = 0
   created_on = ticket.time_created
   updated_on = ticket.time_modified
   start_date = ticket.time_created
   done_ratio = 0
   estimated_hours = 0
   parent_id = nil
   root_id = ticket.id
   lft = 1
   rgt = 2
   is_private = 0
  end

  def find_status_id(status)
    puts "TBD: Redmine::find_status_id(#{status})"
  end

  def find_version_id(version)
    puts "TBD: Redmine::find_version_id(#{version})"
  end

  def find_priority_id(priority)
    puts "TBD: Redmine::find_priority_id(#{priority})"
  end

  def find_user_id(user)
    puts "TBD: Redmine::find_user_id(#{user})"
  end

  def find_category_id(category)
    puts "TBD: Redmine::find_category_id(#{category})"
  end

  def find_tracker_id(type)
    puts "TBD: Redmine::find_tracker_id(#{type})"
  end

  def find_project_id(project)
    puts "TBD: Redmine::find_project_id(#{project})"
  end

  def create_comment(comment)
    puts "TBD: Redmine::create_comment(#{comment})"
  end

  def has_ticket(ticket)
    redmine_ticket = @server.query("select subject from issues where id=#{ticket.id};").fetch_row
    if redmine_ticket.nil?
      return false
    end

# Redmine has a ticket with the same ID, but not the same subject - either the importer has a bug, or your redmine database is polluted.
    if redmine_ticket[0] != ticket.subject
      fail "FATAL IMPORTER ERROR in Redmine::has_ticket! Incoming ticket ID:#{ticket.id} has subject '#{ticket.subject}' and Redmine ticket has subject '#{redmine_ticket[0]}'"
    end

    return true
  end

  def get_comments_for_ticket(ticket)
    comments_from_server = @server.query("select created_on,user_id,notes from journals where journalized_id=#{ticket.id};")
    comments = Array.new

    for comment in comments_from_server
      comments.push(Comment.new(ticket.id, comment[0], find_user(comment[1]), comment[2]))
    end

    return comments
  end

  def disconnect
    @server.close
  end

end
