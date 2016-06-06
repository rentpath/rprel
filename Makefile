BINARY=rprel

.PHONY: build
build: install
	@MIX_ENV=prod mix escript.build

.PHONY: install
install:
	mix deps.get

.PHONY: test
test: install
	mix test

.PHONY: clean
clean:
	@rm -rf $(BINARY)
