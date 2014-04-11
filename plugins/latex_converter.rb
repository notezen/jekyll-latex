require 'securerandom'

module Jekyll
  class LatexConverter < Converter
    safe true
    #priority :low
    
    OPTS={'linenos'=>'linenos','firstnumber'=>'linenostart'}
    
    def setup
      @highlighter ||= Jekyll::Highlighter.new(@config['highlighter'].to_s.downcase)
    end
    
    def matches(ext)
      ext =~ /^\.tex$/i
    end
    
    def output_ext(ext)
      ".html"
    end
    
    def convert(content)
      setup
    
      block_id=SecureRandom.hex(10)
    
      blocks=[]
      content.gsub!(/\s*\\begin\{minted\}(\[.+?\])?\{(.+?)\}(.*?)\\end\{minted\}\s*|\s*\\inputminted(\[.+?\])?\{(.+?)\}{(.+?)\}\s*/m) do |m|
        m = Regexp.last_match
      
        i1=m[2] ? 1 : 4
      
        opts={}
        m[i1].to_s.scan(/([a-z]+)(=([a-z0-9\.]+))?/) do |m| 
          opts[OPTS[m.first]] = m.last || true
        end
      
        code = m[i1+2]
        unless m[2]
          fname="#{@config['source']}/#{@config['latex']}/#{code}"
          if File::exists?(fname)
            code = File.read(fname)
          else
            p "File #{fname} from \\inputminted not found."
          end
        end
      
        blocks<<@highlighter.render(code,m[i1+1],opts)
      
        block_id
      end
    
      result=IO.popen(["/usr/bin/tth", "-u2","-r","-L"],"r+") do |io|
        io.write(content)
        io.close_write
        result=io.read
      end
    
      result.gsub!(block_id) { |m| blocks.shift }
    
      result
    end
  end
end