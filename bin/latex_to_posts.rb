require 'jekyll'
require "stringex"

config = Jekyll::configuration({})

src="#{config['source']}/#{config['latex']}/"
dst="#{config['source']}/_posts/"


keys_arr = %w(categories tags)
keys = %w(title date) + keys_arr

FileUtils.rm Dir.glob("#{dst}*.tex")

Dir.glob("#{src}[^_]*.tex") do |f|

  content = File.read(f)
  if (md = content.match(/(?<meta>.+)\\end\{abstract\}\s*(?<content>.*)\\end\{document\}/m))
    opts={"layout" => "post"}
    content = md[:content]
    meta = md[:meta]
    abstract = meta.gsub(/.*\\begin\{abstract\}/m,'').gsub(/\\.+\{.+\}\s*/,'').strip
    content = "#{abstract}\n\n#{content}" unless abstract.empty?
    
    meta.scan(/\\(.+?)\{(.*?)\}/) do |k,v|
      if keys.include?(k)
        opts[k]=v
      end
    end
    
    keys_arr.each{ |k| opts[k] = opts[k].split(',')}
    opts["title"].gsub!(/\\/,'')    
    
    content = "#{opts.to_yaml}---\n#{content}"
    date = Date.parse(opts["date"])
    name = "#{date.strftime("%Y-%m-%d")}-#{opts["title"].to_url}.tex"
    File.write(dst+name,content)
  end

end