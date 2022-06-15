.PHONY: all

SRC_FILES := $(basename $(shell find lua/snap -type f -name "*.fnl" -not -name "macros.fnl" | cut -d'/' -f3-))

default: all

all:
	@for f in $(SRC_FILES); do \
		fennel --globals 'vim' --compile lua/snap/$$f.fnl > lua/snap/$$f.lua; \
		done
