class JsGenerator
  def generate(dest_path, prefix, slide_list)
    @prefix = prefix
    @slide_list = slide_list

    template_css = File.read("#{__dir__}/template/css.erb")
    erb_css = ERB.new(template_css)
    @str_css = erb_css.result(binding)

    template_js = File.read("#{__dir__}/template/javascript.erb")
    erb_js = ERB.new(template_js)
    @str_js = erb_js.result(binding)

    template = File.read("#{__dir__}/template/body.erb")
    erb = ERB.new(template)
    body = erb.result(binding)
    js = generate_js(body, prefix)

    File.open("#{dest_path}/#{prefix}.js", mode = "w"){|f|
      f.write(js)
    }
  end
end
