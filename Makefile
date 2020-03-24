include Makefile.inc

BUILD_DIR = build
META_ARG =--metadata-file=metadata.yml
ARGS = $(META_ARG) -N --toc --top-level-division=chapter -V fontsize=11pt -V papersize:"a4paper" -N  --lua-filter=tools/scenebreak.lua
PDF_ARGS =  -V geometry:margin=1in --pdf-engine=xelatex --include-in-header header.inc
DOCX_ARGS = -V gemoetry:margin=1in  --reference-doc=styles.docx
EPUB_ARGS= 

html:
	pandoc $(ARGS) -o $(BUILD_DIR)/$(OUTPUT).html -s $(CHAPTERS)

pdf:
	pandoc $(ARGS) $(PDF_ARGS) -o $(BUILD_DIR)/$(OUTPUT).pdf -s $(CHAPTERS)

docx:
	pandoc $(ARGS) $(DOCX_ARGS) -o $(BUILD_DIR)/$(OUTPUT).docx -s $(CHAPTERS)

epub:
	pandoc $(ARGS) $(EPUB_ARGS) -o $(BUILD_DIR)/$(OUTPUT).epub -s $(CHAPTERS)