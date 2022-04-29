.DEFAULT_GOAL := all
.PHONY: all

targets := $(patsubst %.dhall,%.yaml,$(shell ls *.dhall))

all: ${targets}

clean:
	rm ${targets}

%.yaml: %.dhall ./dhall/**/*.dhall
	dhall-to-yaml --generated-comment --file $< --output $@
