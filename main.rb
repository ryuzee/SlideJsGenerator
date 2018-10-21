require 'optparse'
require "digest/md5"
require 'fileutils'
require 'erb'
require './util.rb'
require './js_generator.rb'
require './environment.rb'

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
dest_path = "#{__dir__}/output/#{base}"
FileUtils.mkdir_p(dest_path)
FileUtils.copy(option[:filename], "#{dest_path}/#{base}.pdf")

JsGenerator.new.generate(dest_path, base)

Environment.new.clean(dest_path)

exit 0
