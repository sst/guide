# Create note formatted block
# Indicates information the reader should be aware of
module Jekyll
  class Note < Liquid::Block

    def render(context)
      site = context.registers[:site]
      converter = site.find_converter_instance(::Jekyll::Converters::Markdown)
      aside_content = super

      <<-HTML.gsub /^\s+/, '' # remove whitespaces from heredocs
      <aside class="aside-note">
        <h4 class="extra-note">
          Note
        </h4>
        <div>
          #{converter.convert(aside_content)}
        </div>
      </aside>
      HTML
    end
  end
end

Liquid::Template.register_tag('note', Jekyll::Note)
