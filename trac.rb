require 'rubygems'
require 'mysql'

require './ticket.rb'
require './comment.rb'

class Trac

  def initialize(username, password, server, database)
    @server = Mysql.real_connect(server, username, password, database)
  end

  def get_ticket_by_id(id)
    fields = @server.query("select id,version,reporter,owner,type,status,component,priority,time,changetime,summary,description from ticket where id=#{id};").fetch_row

    return nil if fields.nil?

    project = convert_component_to_project_and_category(fields[6])[0]
    category = convert_component_to_project_and_category(fields[6])[1]
    bugtype = get_bug_type(id)
    likelihood = get_likelihood(id)
    return Ticket.new(fields[0], fields[1], fields[2], fields[3], fields[4], fields[5], project, category, fields[7], fields[8], fields[9], fields[10], fields[11], likelihood, bugtype)
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
    comments_from_trac = @server.query("select time,author,newvalue from ticket_change where field='comment' and ticket=#{ticket.id}")
    comments = Array.new

    for comment in comments_from_trac
# No sense in migrating empty comments or commit messages (redmine will automatically match them up via the repository
      if comment[2].empty? || (comment[2] =~ /.*(Deploy|deploy|refs|Refs|ReFs|Ref|ref|REfs|fixes|Fixes|fix|Fix|see|closes|Closes).*\##{ticket.id}.*/).nil? == false
        next
      end
      comments.push(Comment.new(ticket.id, comment[0], comment[1], comment[2]))
    end

    return comments
  end

  def disconnect
    @server.close
  end
end
