# ===== PDF generation ======================================================
#
# 1. Copy _chapters content to temporal folder
# 2. Merge all chapters in one file and aply modifications with build-book.rb
# 3. Run pandoc with pdf and epub options
#
# ===== Usage ===============================================================
#
# make                   generate pdf and epub
# make pdf               generate pdf
# make ebup              generate epub
# make test              use a short file as input for quick generation
# make test-pdf
# make test-epub
# make clean             delete temporal folder
# ===========================================================================


PDF_NAME = serverless-stack
PDF_OPTIONS = --pdf-engine=xelatex --from=markdown -V book -V classoption=oneside --toc --toc-depth=2 --top-level-division=chapter
PDF_FONTS = -V mainfont="Source Sans Pro" -V monofont="Courier"
PDF_STYLE = --template=./eisvogel --highlight-style="tango"

all: merge_chapters pdf epub clean

merge_chapters:
	mkdir _temp
	cp -r ../../_chapters/* _temp/
	ruby build-book.rb

pdf: full-book.md
	pandoc full-book.md -o $(PDF_NAME).pdf $(PDF_OPTIONS) $(PDF_FONTS) $(PDF_STYLE)

epub: full-book.md
	pandoc full-book.md -o $(PDF_NAME).epub

test: test-book.md
	pandoc test-book.md -o $(PDF_NAME)-test.pdf $(PDF_OPTIONS) $(PDF_FONTS) $(PDF_STYLE)
	pandoc test-book.md -o $(PDF_NAME).epub

test-pdf: clean test-book.md
	pandoc test-book.md -o $(PDF_NAME)-test.pdf $(PDF_OPTIONS) $(PDF_FONTS) $(PDF_STYLE)

test-epub: test-book.md
	pandoc test-book.md -o $(PDF_NAME)-test.epub

clean:
	rm -f _temp

.PHONY: all merge_chapters pdf epub clean test test-epub test-book
