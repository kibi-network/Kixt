SPEC := $(wildcard -/*/index.md)
ABNF := $(patsubst -/%/index.md,ABNF/%,$(SPEC))

tools: abnf

abnf: $(ABNF)

$(ABNF): ABNF/%: -/%/index.md Scripts/generateABNF/index.js | Scripts/generateABNF/node_modules/
	node Scripts/generateABNF $< $@

Scripts/generateABNF/node_modules/:
	cd Scripts/generateABNF && npm install

.PHONY: tools abnf
