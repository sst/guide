# Create aside formatted block
# Provides extra information to the reader.
module Jekyll
  class Caution < Liquid::Block
    def render(context)
      site = context.registers[:site]
      converter = site.find_converter_instance(::Jekyll::Converters::Markdown)
      aside_content = super

      <<-HTML.gsub /^\s+/, '' # remove whitespaces from heredocs
      <aside class="caution">
        <h5>Caution</h5>
        <div>
          #{converter.convert(aside_content)}
        </div>
      </aside>
      HTML
    end
  end
end

Liquid::Template.register_tag('caution', Jekyll::Caution)
