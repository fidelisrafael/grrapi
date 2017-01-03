require 'pry'

def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end


module GrappiTemplate
  def init_template_action!
    puts "Silence is golden"
  end
end

extend GrappiTemplate

init_template_action!


