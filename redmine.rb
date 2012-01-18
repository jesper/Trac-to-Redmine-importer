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
    version = @server.query("select name from versions where id=#{id};").fetch_row
    return nil if id.nil? or version.nil?
    return version[0]
  end

  def find_likelihood_id
    return @server.query("select id from custom_fields where name='Likelihood';").fetch_row[0]
  end

  def find_bug_type_id
    return @server.query("select id from custom_fields where name='Bug-Type';").fetch_row
  end

  def find_likelihood(id)
    likelihood = @server.query("select value from custom_values where customized_id=#{id} and custom_field_id=#{find_likelihood_id};").fetch_row
    return nil if id.nil? or likelihood.nil?
    return likelihood[0]
  end

  def find_bugtype(id)
    bugtype = @server.query("select value from custom_values where customized_id=#{id} and custom_field_id=#{find_bug_type_id};").fetch_row
    return nil if bugtype.nil? or id.nil?
    return bugtype[0]
  end

  def find_user(id)
    user = @server.query("select login from users where id=#{id}").fetch_row
    return nil if id.nil? or user.nil?
    return user[0]
  end

  def find_priority(id)
    priority = @server.query("select name from enumerations where id=#{id} and type='IssuePriority'").fetch_row
    return nil if id.nil? or priority.nil?
    return priority[0]
  end

  def find_issue_type(id)
    return @server.query("select name from trackers where id=#{id}").fetch_row[0]
  end

  def find_status(id)
    status = @server.query("select name from issue_statuses where id=#{id}").fetch_row
    return nil if status.nil? or id.nil?
    return status[0]
  end

  def find_category(id)
    category = @server.query("select name from issue_categories where id=#{id}").fetch_row
    return '' if id.nil? or category.nil?
    return category[0]
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
   id = ticket.id
   tracker_id = find_tracker_id(ticket.type)
   project_id = find_project_id(ticket.project)
   subject = ticket.subject
   description = ticket.description
   due_date = nil
   category_id = find_category_id(project_id, ticket.category)
   status_id = find_status_id(ticket.status)
   assigned_to_id = find_user_id(ticket.assignee)
   priority_id = find_priority_id(ticket.priority)
   fixed_version_id = find_version_id(project_id, ticket.time_created, ticket.version)
   author_id = find_user_id(ticket.author)
   lock_version = 0
   created_on = ticket.time_created
   updated_on = ticket.time_modified
   done_ratio = 0
   estimated_hours = 0
   parent_id = nil
   root_id = ticket.id
   lft = 1
   rgt = 2
   is_private = 0

   puts "ID: #{ticket.id} | #{id}"
   puts "Tracker: #{ticket.type} | #{tracker_id}"
   puts "Project: #{ticket.project} | #{project_id}"
   puts "Subject: #{subject}"
   puts "Description: #{description}"
   puts "Category: #{ticket.category} | #{category_id}"
   puts "Status: #{ticket.status} | #{status_id}"
   puts "Assigned to: #{ticket.assignee} | #{assigned_to_id}"
   puts "Priority: #{ticket.priority} | #{priority_id}"
   puts "Version: #{ticket.version} | #{fixed_version_id}"
   puts "Author: #{ticket.author} | #{author_id}"
   query = @server.prepare("INSERT INTO issues (id, tracker_id, project_id, subject, description, category_id, status_id, assigned_to_id, priority_id, fixed_version_id, author_id, created_on, updated_on, lft, rgt) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")
   query.execute(id.to_s, tracker_id.to_s, project_id.to_s, subject, description, category_id.to_s, status_id.to_s, assigned_to_id.to_s, priority_id.to_s, fixed_version_id.to_s, author_id.to_s, created_on, updated_on, lft.to_s, rgt.to_s)
   #TBD likelihood & bugtype
  end

  def find_status_id(status)
    id = @server.query("select id from issue_statuses where name='#{status}';").fetch_row
    if id.nil?
      puts "Status #{status} not found - creating ..."
      return find_status_id(status)
    end

    return id[0]
  end

  def find_version_id(project_id,date,version)
    return nil if version.nil? || version == ''
    id = @server.query("select id from versions where project_id=#{project_id} and name='#{version}';").fetch_row

    if id.nil?
 #| id | project_id | name | description | effective_date | created_on          | updated_on          | wiki_page_title | status | sharing |
      puts "Creating version #{version} for Project ID:#{project_id}"
      @server.query("INSERT INTO versions (project_id, name, updated_on, created_on) VALUES (#{project_id}, '#{version}', '#{date}', '#{date}');");
      return find_version_id(project_id, date, version)
    end

    return id
  end

  def find_priority_id(priority)
    return nil if priority.nil?

    id = @server.query("select id from enumerations where name='#{priority}' and type='IssuePriority' limit 1").fetch_row
    if id.nil?
      puts "Add priority #{priority}!"
      return find_priority_id(priority)
    end

    return id[0]
  end

  def find_user_id(user)
    id = @server.query("select id from users where login='#{user}';").fetch_row
    return nil if user.nil? or id.nil?
    return id
  end

  def find_category_id(project_id,category)
    return nil if category == ''

    id = @server.query("select id from issue_categories where project_id='#{project_id}' and name='#{category}';").fetch_row

    if id.nil?
      puts "Missing Category #{category} for PROJECT ID:#{project_id} - Creating ..."
      @server.query("INSERT INTO issue_categories (project_id, name) VALUES (#{project_id},'#{category}');")
      return find_category_id(project_id, category)
    end

    return id[0]
  end

  def find_tracker_id(tracker)
    return @server.query("select id from trackers where name='#{tracker}' limit 1").fetch_row[0]
  end

  def find_project_id(project)
    puts "Project: #{project}"
    return @server.query("select id from projects where name='#{project}' limit 1").fetch_row[0]
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
