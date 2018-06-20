GOFMT_FILES?=$$(find . -name '*.go' | grep -v vendor)

default: build
### build will do nothing because there is nothing to build
build: ;
fmt: ;goimports -w $(GOFMT_FILES)

cmd := GOCACHE=off go test -v -timeout 30m
test: ;$(cmd)

.PHONY: build fmt test