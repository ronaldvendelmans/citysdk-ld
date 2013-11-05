require 'json'

# Modified from https://gist.github.com/ahgittin/1895282 
# Reads json from config.json in Jekyll root
 
# usage:  {% jsonconfig config %}
# and then later refer to {{ config.x }} to get x inserted
 
module JekyllJsonConfig
  class JsonConfigTag < Liquid::Tag
 
    def initialize(tag_name, text, tokens)
      super
      @text = text
    end
 
    def render(context)
    	if /(.+) from (.+)/.match(@text)
        config = File.read("./config.json")
    		context[$1] = JSON config
    		return ''
    	end

    	# syntax error
    	return 'ERROR:bad_jsonball_syntax'
    end
 
 
    # def render(context)
#       if /(.+)/.match(@text)
#         config = File.read('./config.json')
# 
#         context[$1] = JSON config
#         return ''
#       end
#   
#       # syntax error
#       return 'ERROR:bad_jsonconfig_syntax'
#     end
 
  end
end
 
Liquid::Template.register_tag('jsonconfig', JekyllJsonConfig::JsonConfigTag)