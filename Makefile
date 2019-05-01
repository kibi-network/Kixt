SPEC := $(wildcard -/*/index.md)
ABNF := $(patsubst -/%/index.md,ABNF/%,$(SPEC))

tools: abnf

abnf: $(ABNF)

$(ABNF): ABNF/%: -/%/index.md Scripts/generateABNF.js
	node Scripts/generateABNF $< $@

.PHONY: tools abnf
