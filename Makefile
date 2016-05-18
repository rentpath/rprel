SOURCEDIR=.
SOURCES := $(shell find $(SOURCEDIR) -name '*.go')

BINARY=rprel

VERSION=1.0.0
BUILD_TIME=`date +%FT%T%z`

GOFLAGS ?= $(GOFLAGS:)
LDFLAGS=-ldflags "-X github.com/rentpath/$(BINARY)/core.Version=${VERSION} -X github.com/ariejan/$(BINARY)/core.BuildTime=${BUILD_TIME}"

.PHONY: all
all: install test

.PHONY: build
build: $(SOURCES)
	@go build $(GOFLAGS) ${LDFLAGS} -o ${BINARY} ./...

.PHONY: install
install:
	@go install $(GOFLAGS) ./...

.PHONY: test
test: install
	@go test $(GOFLAGS) ./...

.PHONY: bench
bench: install
	@go test -run=NONE -bench=. $(GOFLAGS) ./...

.PHONY: clean
clean:
	@go clean $(GOFLAGS) -i ./...