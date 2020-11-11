require 'yaml'

$config = YAML.load_file('../../_config.yml');
$changelog = YAML.load_file('../../_data/changelog.yml');
$hasWarning = false;

# Discourse link at end of chapters
def discourse_link comments_id
    link = "
<div class=\"post-links\">
  <p>For help and discussion</p>
  <a target=\"_blank\" href=\"#{$config['forum_url']+$config['forum_thread_prefix']+comments_id}\">
    Comments on this chapter
  </a>
</div>
"
end

# Github code link at end of chapters
def github_code_link code_link, chapter_name
    backend_github_repo = $config['backend_github_repo']
    frontend_github_repo = $config['frontend_github_repo']
    frontend_fb_login_github_repo = $config['frontend_fb_login_github_repo']
    frontend_user_mgmt_github_repo = $config['frontend_user_mgmt_github_repo']
    backend_mono_github_repo = $config['backend_mono_github_repo']

    if (code_link === 'backend_full')
      text = "For reference, here is the complete code for the backend"
    elsif (code_link == 'frontend_full')
      text = "For reference, here is the complete code for the frontend"
    else
      text = "For reference, here is the code we are using"
    end

    if (code_link === 'backend')
        link_text = "Backend Source: #{chapter_name}"
        link = "#{backend_github_repo}/tree/#{chapter_name}"

    elsif (code_link === 'frontend')
        link_text = "Frontend Source: #{chapter_name}"
        link = "#{frontend_github_repo}/tree/#{chapter_name}"

    elsif (code_link === 'backend_full')
        link_text = "Backend Source"
        link = "#{backend_github_repo}"

    elsif (code_link === 'frontend_full')
        link_text = "Frontend Source"
        link = "#{frontend_github_repo}"

    elsif (code_link === 'mono-repo')
        link_text = "Mono-repo Backend Source"
        link = "#{backend_mono_github_repo}"

    elsif (code_link === 'facebook-login')
        link_text = "Facebook Login Frontend Source"
        link = "#{frontend_fb_login_github_repo}"

    elsif (code_link === 'user-management')
        link_text = "User Management Frontend Source"
        link = "#{frontend_user_mgmt_github_repo}"
    end

    link = "
<div class=\"post-checkpoint\">
  <p>#{text}</p>
  <a target=\"_blank\" href=\"#{link}\">
    #{link_text}
  </a>
</div>
"
end

def build_chapter chapter_data
    chapter_name = chapter_data['url'].split('/').last.split('.').first

    # Read chapter file
    chapter = File.read("../../_chapters/#{chapter_name}.md")

    chapter.force_encoding(::Encoding::UTF_8)

    chapter_front_matter = YAML.load_file("../../_chapters/#{chapter_name}.md")

    #################
    # Validations
    #################
    # Validate codeblocks ``` without language
    codeblocks = chapter.scan(/```.*$/)
    if codeblocks.length().odd?
      $hasWarning = true;
      warn("Warning: Odd number of codeblock ticks")
    end
    for i in 0..(codeblocks.length() - 1) do
      if i.even? && codeblocks[i].chomp === '```'
        $hasWarning = true;
        warn("Warning: Detected codeblock without language definition in chapter #{chapter_name}")
      end
    end

    #################
    # Replace content
    #################
    # Replace front matter data with only markdown title
    chapter = chapter.gsub(/---[\s\S]*?title:([^\r\n]*)[\s\S]*?---/, "## \\1\n")

    # Replace images path
    chapter = chapter.gsub(/\/assets\//, '../../assets/')

    # Remove class in table
    chapter = chapter.gsub('{: .cost-table }', '')

    # Remove {% raw %} and {% endraw %} tags
    chapter = chapter.gsub(/{% (raw|endraw) %}/, '')

    # Replace site variables
    $config.each do |variable|
      chapter = chapter.gsub(/{{ site.#{variable[0].to_s} }}/, variable[1].to_s)
    end
    if (chapter_name === 'changelog')
      $changelog.each do |variable|
        chapter = chapter.gsub(/{{ site.data.changelog.#{variable[0]}.title }}/, variable[1]['title'])
        chapter = chapter.gsub(/{{ site.data.changelog.#{variable[0]}.desc }}/, variable[1]['desc'])
      end
    end

    # Replace codeblock change icon
    chapter = chapter.gsub(/\{%\s*change\s*%}/, '<img class="code-marker" src="../../assets/change-marker.png" />')

    # Replace links to chapters
    # ie. [Chapter Name]({% link _chapters/chapter-file.md %}) => [Chapter Name][chapter file]
    chapter = chapter.gsub(/\[([^\]]*)\]\({% link _chapters\/(.*?)\.md %}\)/) {
      '[' << Regexp.last_match[1] << '][' << Regexp.last_match[2].gsub('-', ' ') << ']'
    }

    # Link to sections
    chapter = chapter.gsub(/\[([^\]]*)\]\({% link _chapters\/(.*?)\.md %}#(.*?)\)/) {
      '[' << Regexp.last_match[1] << '][' << Regexp.last_match[3].gsub('-', ' ') << ']'
    }

    # Non-chapter links ie. {% link sponsors.md %}
    chapter = chapter.gsub(/\{% link ([A-Za-z0-9][^.]*)\.md %}/, "#{$config['url']}/\\1")

    # GitHub link
    if (chapter_front_matter['code'])
      chapter << github_code_link(chapter_front_matter['code'], chapter_name)
    end

    # Discourse link
    chapter << discourse_link(chapter_front_matter['comments_id'])

    # Replace chapter specific content
    if (chapter_name === 'wrapping-up-the-best-practices')
      # Remove the survey http link button. The survey link already exist in the paragraph
      # before it, it is redundant.
      chapter = chapter.gsub(/<a.*>Fill out our survey<\/a>/, "")
    end

    # Add some additional break lines
    chapter = chapter.chomp
    chapter << "\n\n\n"

    # Add subchapters
    if (chapter_data['subchapters'])
      chapter_data['subchapters'].each do |subchapter|
        chapter << build_chapter(subchapter)
      end
    end

    chapter
end

def merge_chapters
    File.open('output/epub.md', 'w') do |file|

        # Load sections from chapter list
        chapter_list = YAML.load_file('../../_data/chapterlist.yml')
        chapter_list.each do |section_key, section|

          file << "# " << section['title'] << "\n\n"

          # Handle each section
          section['chapters'].each do |chapter_data|
            # Uncomment to generate for specific chapters
            # TODO
            #if (chapter_data["url"] != '/chapters/deploy-your-serverless-infrastructure.html' && chapter_data["url"] != '/chapters/manage-environment-related-config.html')
            #  next
            #end
            file << build_chapter(chapter_data)
          end
        end
    end
end

merge_chapters

if $hasWarning
  exit(1)
end
