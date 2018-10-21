class JsGenerator
  def generate(dest_path, prefix)
    @prefix = prefix

    pdf_to_ppm(dest_path, "#{prefix}.pdf")
    @slide_list = ppm_to_jpg(dest_path)

    template_css = File.read("#{__dir__}/template/css.erb")
    erb_css = ERB.new(template_css)
    str_css = erb_css.result(binding)

    template_js = File.read("#{__dir__}/template/javascript.erb")
    erb_js = ERB.new(template_js)
    js = erb_js.result(binding)
    str_js = js.gsub('OSSJSPARTS', "OSSJSPARTS#{prefix}").gsub('PREFIX', prefix)

    template = File.read("#{__dir__}/template/body.erb")
    erb = ERB.new(template)
    body = erb.result(binding)
    body = body + str_css + str_js
    js = generate_js(body, prefix)

    File.open("#{dest_path}/slide.js", mode = "w"){|f|
      f.write(js)
    }
    STDOUT.print "Succeed to generate javascript.\nYou can include the script as follows.\n<script src=\"#{prefix}/slide.js\"></script>\n"
  end

  private

  def convert_line(str)
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
var current_#{prefix} = (function() {
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
      script = script.concat(convert_line(s)) + "\n"
    end
    require 'uglifier'
    Uglifier.compile(script)
  end
end
