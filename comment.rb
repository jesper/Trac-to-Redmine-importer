class Comment
  attr_accessor :parent, :time, :author, :text
  def initialize(parent, time, author, text)
    @parent = parent
    @time = time
    @author = author
    @text = text
  end

  def to_s
    "PARENT[#{parent}]TIME[#{time}]AUTHOR[#{author}]TEXT[#{text}]"
  end
end
