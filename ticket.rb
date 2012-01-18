class Ticket
  attr_accessor :id, :version, :author, :assignee, :type, :status, :project, :category, :priority, :time_created, :time_modified, :subject, :description, :likelihood, :bugtype
  def initialize(id, version, author, assignee, type, status, project, category, priority, time_created, time_modified, subject, description, likelihood, bugtype)
    @dictionary = {'Blocker: Prevents further development' => 'Critical', 'Critical: User would stop using the product' => 'Urgent', 'Major: Discourages User, noteworthy critique in reviews' => 'High', 'Minor: Causes minor User discomfort' => 'Normal', 'Trivial: Not a big deal, but noticeable' => 'Low', nil => 'Low', 'pending' => 'Low', 'in-development' => 'In Progress', 'dev-testing'=>'Testing', 'change' => 'Refactor', 'awaiting-spec' => 'New', 'triaged' => 'New', 'awaiting-design' => 'New', 'spec-design-ok' => 'New', 'awaiting-deployment' => 'Resolved', 'stage-build-testing' => 'Testing'}
    @id = id.to_i
    @version = version
    @author = author
    @assignee = assignee
    @type = translate(type)
    @status = translate(status)
    @project = project
    @category = category
    @priority = translate(priority)
    @time_created = time_created
    @time_modified = time_modified
    @subject = subject
    @description = description
    @likelihood = likelihood
    @bugtype = bugtype
  end

  def translate(word)
    translated = @dictionary[word]
    return word if translated.nil?
    return translated
  end

  def ==(other)
    @id == other.id
  end

  def <=(other)
    @id <= other.id
  end

  def to_s
    "ID[#{id}]-SUBJECT[#{subject}]"
  end
end


