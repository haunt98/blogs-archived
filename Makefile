.PHONY: all test test-color coverage coverage-cli coverage-html lint format gen format-html

all:
	go mod tidy
	$(MAKE) test-color
	$(MAKE) lint
	$(MAKE) format
	$(MAKE) gen
	$(MAKE) format-html

test:
	go test -race -failfast ./...

test-color:
	go install github.com/haunt98/go-test-color@latest
	go-test-color -race -failfast ./...

coverage:
	go test -coverprofile=coverage.out ./...

coverage-cli:
	$(MAKE) coverage
	go tool cover -func=coverage.out

coverage-html:
	$(MAKE) coverage
	go tool cover -html=coverage.out

lint:
	golangci-lint run ./...

format:
	go install github.com/haunt98/gofimports/cmd/gofimports@latest
	go install mvdan.cc/gofumpt@latest
	gofimports -w --company github.com/make-go-great .
	gofumpt -w -extra .

gen:
	go run .

format-html:
	bun install prettier
	bun prettier --write .
