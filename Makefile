CLANG ?= clang
CFLAGS := -O2 -g -Wall -Werror $(CFLAGS)


.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


.PHONY: generate-ebpf
generate-ebpf: export BPF_CLANG := $(CLANG)
generate-ebpf: export BPF_CFLAGS := $(CFLAGS)
generate-ebpf: ## Generate the ebpf code and lib
	go generate ./...


goimports:
ifeq (, $(shell which goimports))
	@{ \
	echo "goimports not found!";\
	echo "installing goimports...";\
	go get golang.org/x/tools/cmd/goimports;\
	}
else
GO_IMPORTS=$(shell which goimports)
endif

.PHONY: fmt
fmt: ## Run go fmt against code.
	go fmt ./... && $(GO_IMPORTS) -w ./

.PHONY: vet
vet: ## Run go vet against code.
	go vet ./...

.PHONY: test-unit
test-unit: ## Run unit tests
	@echo "	running unit tests"
	go test ./... -coverprofile coverage.out

.PHONY: test
test: test-unit ## Run tests.

.PHONY: build
build: generate-ebpf fmt vet
	go build -o bpfescapego

.PHONY: update-libbpf
update-libbpf: 
	cd pkg/c/headers && ./update.sh
	bpftool btf dump file /sys/kernel/btf/vmlinux format c > pkg/c/headers/vmlinux.h

.PHONY: main-test
main-test: generate-ebpf
	sudo go run main.go