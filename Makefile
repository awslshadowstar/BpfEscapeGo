CLANG ?= clang
CFLAGS := -O2 -g -Wall -Werror $(CFLAGS)


.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: get-bpftool
get-bpftool:
	which bpftool >/dev/null 2>&1 || (echo download_bpftool && wget https://github.com/libbpf/bpftool/releases/download/v7.4.0/bpftool-v7.4.0-amd64.tar.gz && tar -xvf bpftool-v7.4.0-amd64.tar.gz && install bpftool /usr/local/bin && rm bpftool*)
	sudo apt install clang llvm -y

.PHONY: mod-download
mod-download:
	go mod download

.PHONY: generate-ebpf
generate-ebpf: export BPF_CLANG := $(CLANG)
generate-ebpf: export BPF_CFLAGS := $(CFLAGS)
generate-ebpf: mod-download
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
build: generate-ebpf 
	go build -o BpfEscapeGo

.PHONY: get-header
get-header:
	cd pkg/headers && ./update.sh

.PHONY: update-libbpf
update-libbpf: get-bpftool
	bpftool btf dump file /sys/kernel/btf/vmlinux format c > pkg/headers/vmlinux.h

.PHONY: main-test
main-test: generate-ebpf
	sudo go run main.go