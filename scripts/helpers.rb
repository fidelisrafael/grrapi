module GrappiTemplate

  BASE_DIR = File.expand_path(File.join('..', 'template_files'))

  module Helpers
    protected def app_name
      ARGV[1].underscore rescue 'application'
    end

    protected def copy_directory(src, dest)
      directory File.join(BASE_DIR, src), dest
    end

    def copy_file_to(file_src, file_dest = nil)
      copy_file File.join(BASE_DIR, file_src), file_dest || File.basename(file_src)
    end
  end
end