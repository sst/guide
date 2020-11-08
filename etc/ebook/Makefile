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

OUTPUT_DIR = output
FILE_NAME = serverless-stack

pdf: prepare merge-pdf build-pdf
epub: prepare merge-epub build-epub

start:
	docker build -t serverless-stack-ebook .
	docker run -it --rm --volume "`pwd`/../..:/data" --entrypoint /bin/bash serverless-stack-ebook

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
		-V mainfont="Lato" \
		-V monofont="Source Code Pro" \
		-V monofontoptions="Scale=0.9" \
		-V sansfont="PT Serif" \
		--template="./eisvogel" \
		--highlight-style="tango" \
		-V urlcolor="serverless-purple" \
		--metadata date="`date "+%B %e, %Y"` - $(BOOK_VERSION)" \
		--fail-if-warnings

build-epub:
	pandoc metadata-epub.txt $(OUTPUT_DIR)/epub.md -o $(OUTPUT_DIR)/$(FILE_NAME).epub \
		--epub-embed-font='fonts/Lato/*.ttf' \
		--epub-embed-font='fonts/PTSerif/*.ttf' \
		--epub-embed-font='fonts/SourceCodePro/*.ttf' \
		--epub-chapter-level=2 \
		--epub-cover-image='cover.jpeg' \
		--toc-depth=2 \
		--top-level-division=chapter \
		--highlight-style="tango" \
		--metadata date="`date "+%B %e, %Y"` - $(BOOK_VERSION)" \
		--fail-if-warnings

.PHONY: all build pdf epub
