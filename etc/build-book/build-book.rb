chapters_order = File.readlines('chapters-order.txt')

# Discourse link at end of chapters
def discourse_link chapter_name
    link = "\n**For help and discussion**\n\n[Comments on this chapter](https://discourse.serverless-stack.com/t/#{chapter_name})"
end

File.open('full-book.md', 'w') do |file|
    # Add metadata and introduction
    file << File.read('pdf-metadata.md')
    file << "\n\n"

    # Loop in chapters
    chapters_order.each do |chapter_name|
        chapter_name = chapter_name.chomp

        # Read chapter file
        chapter = File.read("_temp/#{chapter_name}.md")

        # Replace front matter data with only markdown title
        chapter = chapter.gsub(/---[\s\S]*?title:([^\r\n]*)[\s\S]*?---/, '# \1')

        # Replace h3 headers with h2 headers
        chapter = chapter.gsub(/###/, '##')

        # Replace images path
        chapter = chapter.gsub(/\/assets\//, '../../assets/')

        # Remove class in table
        chapter = chapter.gsub('{: .cost-table }', '')

        # Add discourse link
        chapter << discourse_link(chapter_name)

        # Replace ✓ character in jest snippet to avoid pandoc error
        # Realy its a issue of the monofont selected, because hasn't this character
        if ( chapter_name === 'unit-tests-in-serverless')
            chapter.force_encoding(::Encoding::UTF_8)
            chapter = chapter.gsub('✓', '[passed]')
        end

        # Add some additional break lines
        file << chapter.chomp << "\n\n\n"
    end
end
