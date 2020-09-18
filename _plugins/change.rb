module Jekyll
  class Change < Liquid::Tag
    def render(context)
      "<img class=\"code-marker\" src=\"/assets/s.png\" />"
    end
  end
end

Liquid::Template.register_tag('change', Jekyll::Change)
