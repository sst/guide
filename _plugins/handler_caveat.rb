# Replace {%ensure_sst_dev_running%} with an image
# Indicates that the reader needs to have `sst dev` running
module Jekyll
  class HandlerCaveat < Liquid::Tag
    def render(context)
      site = context.registers[:site]
      converter = site.find_converter_instance(::Jekyll::Converters::Markdown)

      <<-HTML.gsub /^\s+/, '' # remove whitespaces from heredocs
        <aside class="aside-note">
        <h4 class="extra-note">
          Important
        </h4>
          <div>
            #{converter.convert(caveat)}
          </div>
        </aside>
      HTML
    end

    def caveat
<<-MARKDOWN
The `handler.ts` needs to be **imported before we import anything else**. This is because we'll be adding some error handling to it later that needs to be initialized when our Lambda function is first invoked in order to ensure any and all errors are logged correctly.
MARKDOWN
    end
  end
end

Liquid::Template.register_tag('handler_caveat', Jekyll::HandlerCaveat)
