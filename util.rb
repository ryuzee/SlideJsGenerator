require 'open3'

def pdf_to_ppm(dir, file)
  cmd = "cd #{dir} && pdftoppm #{file} slide"
  result = exec_command(cmd)
  result
end

def rename_to_pdf(dir, file)
  cmd = "cd #{dir} && mv #{file} #{file}.pdf"
  result = exec_command(cmd)
  result
end

def ppm_to_jpg(dir)
  cmd = "cd #{dir} && mogrify -format jpg slide*.ppm"
  result = exec_command(cmd)
  if result
    list = get_local_file_list(dir, '.jpg')
    list
  else
    false
  end
end

def get_local_file_list(dir, extension)
  list = []
  Dir.glob("#{dir}/*#{extension}").each do |f|
    list.push(f)
  end
  list.sort
end

def exec_command(cmd)
  Open3.popen3(cmd) do |_i, o, e, w|
    out = o.read
    err = e.read
    STDERR.print out unless out.empty?
    STDERR.print err unless err.empty?
    return w.value.exitstatus.zero?
  end
rescue StandardError => e
  STDERR.print e.to_s
  false
end
