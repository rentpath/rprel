SOURCEDIR=.
SOURCES := $(shell find $(SOURCEDIR) -name '*.go')

BINARY=rprel

VERSION=0.0.1
BUILD_TIME=`date +%FT%T%z`

GOFLAGS ?= $(GOFLAGS:)
LDFLAGS=-ldflags "-X main.Version=${VERSION} -X main.BuildTime=${BUILD_TIME}"

.PHONY: all
all: install test

.PHONY: build
build: $(SOURCES)
	go build $(GOFLAGS) ${LDFLAGS} -o ${BINARY} rprel.go

.PHONY: install
install:
	go install $(GOFLAGS) ./...

.PHONY: test
test: install
	@go test $(GOFLAGS) ./...

.PHONY: bench
bench: install
	@go test -run=NONE -bench=. $(GOFLAGS) ./...

.PHONY: clean
clean:
	@go clean $(GOFLAGS) -i ./...
