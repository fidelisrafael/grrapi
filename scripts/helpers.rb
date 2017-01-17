module GrappiTemplate

  BASE_DIR = File.expand_path(File.join(File.dirname(__FILE__), 'template_files'))

  module Helpers
    protected def app_name
      Rails.application.class.parent_name.underscore
      # ARGV[1].underscore rescue 'application'
    end

    protected def copy_directory(src, dest = nil)
      new_src = File.join(BASE_DIR, src)
      directory new_src, dest.nil? ? src : dest
    end

    def copy_file_to(file_src, file_dest = nil)
      copy_file File.join(BASE_DIR, file_src), file_dest || file_src
    end
  end
end