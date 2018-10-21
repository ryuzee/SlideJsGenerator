require 'fileutils'
require './util.rb'

class Environment
  def clean(dest_path)
    get_local_file_list(dest_path, '.pdf').each do |f|
      FileUtils.rm_f(f)
    end

    get_local_file_list(dest_path, '.ppm').each do |f|
      FileUtils.rm_f(f)
    end
  end
end
