class Ticket
  attr_accessor :id, :author, :assignee, :type, :status, :project, :category, :priority, :time_created, :time_modified, :subject, :description, :likelihood, :bugtype
  def initialize(id, author, assignee, type, status, project, category, priority, time_created, time_modified, subject, description, likelihood, bugtype)
    @id = id
    @author = author
    @assignee = assignee
    @type = type
    @status = status
    @project = project
    @category = category
    @priority = priority
    @time_created = time_created
    @time_modified = time_modified
    @subject = subject
    @description = description
    @likelihood = likelihood
    @bugtype = bugtype
  end

  def ==(other)
    @id == other.id
  end

  def <(other)
    @id < other.id
  end
end


