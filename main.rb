require 'optparse'
require "digest/md5"
require 'fileutils'
require 'erb'
require './util.rb'

option = {}
OptionParser.new do |opt|
  opt.on('-f value',   '--filename', 'File name to generate slideshow') {|v| option[:filename] = v}
  opt.parse!(ARGV)
end

unless option[:filename] and File.exists?(option[:filename])
  STDERR.print "File does not exist\n"
  exit 1
end

ext = File.extname(option[:filename])
unless ext.downcase == '.pdf'
  STDERR.print "You need to specify PDF file.\n"
  exit 1
end

base = Digest::MD5.hexdigest(File.basename(option[:filename]))
@prefix = base
dest_path = "#{__dir__}/output/#{base}"
FileUtils.mkdir_p(dest_path)

FileUtils.copy(option[:filename], "#{dest_path}/#{base}.pdf")

pdf_to_ppm(dest_path, "#{base}.pdf")
@slide_list = ppm_to_jpg(dest_path)

template_css = File.read("#{__dir__}/template/css.erb")
erb_css = ERB.new(template_css)
@str_css = erb_css.result(binding)

template_js = File.read("#{__dir__}/template/javascript.erb")
erb_js = ERB.new(template_js)
@str_js = erb_js.result(binding)

template = File.read("#{__dir__}/template/body.erb")
erb = ERB.new(template)
body = erb.result(binding)
js = generate_js(body, base)

File.open("#{dest_path}/#{base}.js", mode = "w"){|f|
  f.write(js)
}

get_local_file_list(dest_path, '.pdf').each do |f|
  FileUtils.rm_f(f)
end

get_local_file_list(dest_path, '.ppm').each do |f|
  FileUtils.rm_f(f)
end

exit 0
