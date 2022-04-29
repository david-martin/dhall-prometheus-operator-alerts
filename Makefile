.DEFAULT_GOAL := all
.PHONY: all

targetdir := target
targets := $(addprefix $(targetdir)/,$(patsubst %.dhall,%.yaml,$(shell ls *.dhall)))

all: ${targets}

clean:
	rm ${targets}

$(targetdir)/%.yaml: %.dhall ./dhall/**/*.dhall
	dhall-to-yaml --generated-comment --file $< --output $@

$(targets): | $(targetdir)

$(targetdir):
	mkdir $(targetdir)
