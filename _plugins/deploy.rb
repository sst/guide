# Replace {%ensure_sst_dev_running%} with an image
# Indicates that the reader needs to have `sst dev` running
module Jekyll
  class Deploy < Liquid::Tag
    def render(context)
<<-MARKDOWN
### Deploy our changes

If you switch over to your terminal, you will notice that your changes are being deployed.

> You'll need to have `sst dev` running for this to happen. If you had previously stopped it, then running `pnpm exec sst dev` will deploy your changes again. 

You should see that the new API stack has been deployed.

MARKDOWN
    end
  end
end

Liquid::Template.register_tag('deploy', Jekyll::Deploy)
