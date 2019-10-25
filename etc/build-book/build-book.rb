require 'yaml'

$chapters_order = File.readlines('chapters-order.txt')
$site_variables = YAML.load_file('../../_config.yml');
$changelog = YAML.load_file('../../_data/changelog.yml');

# Discourse link at end of chapters
def discourse_link comments_id
    link = "
\\awesomebox[serverless-purple]{1pt}{\\faComments}{serverless-purple}{
\\textbf{For help and discussion}

Visit the comments for this chapter \\href{#{$site_variables['forum_url']+$site_variables['forum_thread_prefix']}#{comments_id}}{on discourse forum →}
}
"
end

# Github code link at end of chapters
def github_code_link code_link, chapter_name
    backend_github_repo = $site_variables['backend_github_repo']
    frontend_github_repo = $site_variables['frontend_github_repo']
    frontend_fb_login_github_repo = $site_variables['frontend_fb_login_github_repo']
    frontend_user_mgmt_github_repo = $site_variables['frontend_user_mgmt_github_repo']
    backend_mono_github_repo = $site_variables['backend_mono_github_repo']

    if (code_link === 'backend_full' || code_link === 'frontend_full')
        text = "For reference, here is the code for Part II"
    elsif (code_link == 'backend_part1' || code_link == 'backend_part1')
        text = "For reference, here is the code for Part I"
    else
        text = "For reference, here is the code we are using"
    end

    if (code_link === 'backend')
        link_text = "Backend Source: #{chapter_name}"
        link = "#{backend_github_repo}/tree/#{chapter_name}"

    elsif (code_link === 'frontend')
        link_text = "Frontend Source: #{chapter_name}"
        link = "#{frontend_github_repo}/tree/#{chapter_name}"

    elsif (code_link === 'backend_part1')
        link_text = "Backend Part I Source"
        link = "#{backend_github_repo}/tree/handle-api-gateway-cors-errors"

    elsif (code_link === 'frontend_part1')
        link_text = "Backend Part II Source"
        link = "#{backend_github_repo}/tree/part-1"

    elsif (code_link === 'mono-repo')
        link_text = "Mono-repo Backend Source"
        link = "#{backend_mono_github_repo}"

    elsif (code_link === 'facebook-login')
        link_text = "Mono-repo Backend Source"
        link = "#{frontend_fb_login_github_repo}"

    elsif (code_link === 'user-management')
        link_text = "User Management Frontend Source"
        link = "#{frontend_user_mgmt_github_repo}"

    elsif (code_link === 'frontend_full')
        link_text = "Frontend Part II Source"
        link = "#{frontend_github_repo}"
    end

    link = "
\\awesomebox[serverless-purple]{1pt}{\\faGithub}{serverless-purple}{
\\textbf{#{text}}

\\href{#{link}}{#{link_text} →}
}"
end

def merge_chapters
    File.open('full-book.md', 'w') do |file|

        # Add metadata and introduction
        file << File.read('pdf-metadata.md')
        file << "\n\n"

        # Loop in chapters
        $chapters_order.each do |chapter_name|
            chapter_name = chapter_name.chomp

            # Read chapter file
            chapter = File.read("_temp/#{chapter_name}.md")

            chapter.force_encoding(::Encoding::UTF_8)

            chapter_front_matter = YAML.load_file("_temp/#{chapter_name}.md")

            # Replace front matter data with only markdown title
            chapter = chapter.gsub(/---[\s\S]*?title:([^\r\n]*)[\s\S]*?---/, '# \1')

            # Replace h3 headers with h2 headers
            chapter = chapter.gsub(/###/, '##')

            # Replace images path
            chapter = chapter.gsub(/\/assets\//, '../../assets/')

            # Remove class in table
            chapter = chapter.gsub('{: .cost-table }', '')

            # Replace site variables
            $site_variables.each do |variable|
                chapter = chapter.gsub(/{{ site.#{variable[0].to_s} }}/, variable[1].to_s)
            end

            # Add anchor to sections
            chapter = chapter.gsub(/\[([^\]]*)\]\({% link _chapters\/(.*?)\.md %}\)/, '\hyperlink{\2}{\1}')
            chapter = chapter.gsub(/\[([^\]]*)\]\({% link _chapters\/(.*?)\.md %}#(.*?)\)/, '\hyperlink{\3}{\1}')
            # chapter = chapter.gsub(/\[([^\]]*)\]\((https:\/\/.*?)\)/, '\hyperlink{\2}{\1}')
            # chapter = chapter.gsub(/\[([^\]]*)\]\((http:\/\/.*?)\)/, '\hyperlink{\2}{\1}')
            # chapter = chapter.gsub(/(\\hyperlink.*?)#(.*?}{.*?})/, '\1')

            if (chapter_name === 'who-is-this-guide-for')
                chapter = chapter.gsub(/\{% link about.md %}/, "#{$site_variables['url']}/about")
                chapter = chapter.gsub(/\{% link showcase.md %}/, "#{$site_variables['url']}/showcase")
            end

            if (chapter_name === 'changelog')
                $changelog.each do |variable|
                    chapter = chapter.gsub(/{{ site.data.changelog.#{variable[0]}.title }}/, variable[1]['title'])
                    chapter = chapter.gsub(/{{ site.data.changelog.#{variable[0]}.desc }}/, variable[1]['desc'])
                end
            end

            # Add discourse link
            chapter << discourse_link(chapter_front_matter['comments_id'])

            # Add code link if exist
            if (chapter_front_matter['code'])
                chapter << github_code_link(chapter_front_matter['code'], chapter_name)
            end

            # Replace ✓ character in jest snippet to avoid pandoc error
            # Really its an issue of the monofont selected, because hasn't this character
            if ( chapter_name === 'unit-tests-in-serverless')
                chapter.force_encoding(::Encoding::UTF_8)
                chapter = chapter.gsub('✓', '[passed]')
            end

            # Add some additional break lines
            file << chapter.chomp << "\n\n\n"
        end
    end
end

merge_chapters
