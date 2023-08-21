# Create aside formatted block
# Provides extra information to the reader.
module Jekyll
  class Aside < Liquid::Block
    def render(context)
      site = context.registers[:site]
      converter = site.find_converter_instance(::Jekyll::Converters::Markdown)
      aside_content = super

      <<-HTML.gsub /^\s+/, '' # remove whitespaces from heredocs
      <aside class="aside-info">
        <h4 class="extra-info">
          Extra Info
        </h4>
        <div>
          #{converter.convert(aside_content)}
        </div>
      </aside>
      HTML
    end
  end
end

Liquid::Template.register_tag('aside', Jekyll::Aside)
