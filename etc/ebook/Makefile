# ===== PDF generation ======================================================
#
# 1. Merge all chapters in one file and aply modifications with build-book.rb
# 2. Run pandoc with pdf and epub options
#
# ===== Usage ===============================================================
#
# make                   generate pdf and epub
# make build             merge all chapters
# make pdf               generate pdf
# make ebup              generate epub
# ===========================================================================

FILE_NAME = ebook
OUTPUT_DIR = output

pdf: prepare merge-pdf build-pdf
epub: prepare merge-epub build-epub

start:
	docker build -t sst-guide-ebook .
	docker run -it --rm --volume "`pwd`/../..:/data" --entrypoint /bin/bash sst-guide-ebook

prepare:
	mkdir -p $(OUTPUT_DIR)

merge-pdf:
	ruby build-pdf.rb

merge-epub:
	ruby build-epub.rb

build-pdf:
	pandoc $(OUTPUT_DIR)/pdf.md -o $(OUTPUT_DIR)/$(FILE_NAME).pdf \
		--pdf-engine=xelatex \
		--from=markdown \
		-V book \
		-V classoption=oneside \
		--toc \
		--toc-depth=1 \
		--top-level-division=chapter \
		-V mainfont="Source Sans Pro" \
		-V monofont="Source Code Pro" \
		-V monofontoptions="Scale=0.9" \
		-V sansfont="Roboto Slab" \
		--template="./eisvogel" \
		--highlight-style="tango" \
		-V urlcolor="serverless-purple" \
		--metadata date="`date "+%B %e, %Y"` - $(BOOK_VERSION)" \
		--fail-if-warnings

build-epub:
	pandoc metadata-epub.txt $(OUTPUT_DIR)/epub.md -o $(OUTPUT_DIR)/$(FILE_NAME).epub \
		--epub-embed-font='fonts/SourceSansPro/*.ttf' \
		--epub-embed-font='fonts/RobotoSlab/*.ttf' \
		--epub-embed-font='fonts/SourceCodePro/*.ttf' \
		--epub-chapter-level=2 \
		--epub-cover-image='cover.jpeg' \
		--toc-depth=2 \
		--top-level-division=chapter \
		--highlight-style="tango" \
		--metadata date="`date "+%B %e, %Y"` - $(BOOK_VERSION)" \
		--fail-if-warnings

.PHONY: all build pdf epub
