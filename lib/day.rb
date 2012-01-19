class Day
  attr_accessor :title
  attr_accessor :text
  attr_accessor :icon

  def initialize(title, text, icon)
    @title = title ? title : "";
    @text = text ? text : "";
    @icon = icon ? icon : "";
  end
end
