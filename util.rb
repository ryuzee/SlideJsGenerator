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

def conv(str)
  str.gsub!(/(\r\n|\r|\n)/,"")
  str.gsub!(/\\/,"\\\\")
  str.gsub!(/"/,"\\\\\"")
  str.gsub!(/\s+/," ")
  str.strip!
  return "" if str == ""
  "w(\"#{str}\");"
end

def generate_js(text, prefix)
  script = <<"EOS"
var current = (function() {
    if (document.currentScript) {
        return document.currentScript.src;
    } else {
        var scripts = document.getElementsByTagName('script'),
        script = scripts[scripts.length-1];
        if (script.src) {
            return script.src;
        }
    }
})();
EOS

  script = script + "function w(s){document.write(s+'\\n');}\n\n"
  text.each_line do |s|
    script = script.concat(conv(s)) + "\n"
  end
  require 'uglifier'
  Uglifier.compile(script)
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
