IMAGE = quay.io/jemccorm/demo-scorecard-image
SHELL = /bin/bash
# set Go builds flags for cross-compilation in case build system is non-Linux
GO_BUILD_FLAGS = GOOS=linux GOARCH=amd64

all: build

tag-update:
	./tag-update.pl

installrbac: ## run only one time to configure rbac for tests
	kubectl apply -f rbac/

clean: ## Clean up the build artifacts
	rm -f images/demo-custom-scorecard-image/demo-scorecard-tests

build:
	$(GO_BUILD_FLAGS) go build internal/tests/tests.go

image-build: ## Running `make image-build` from the project root of this example test function will build docker test image.
	$(GO_BUILD_FLAGS) go build -o images/demo-scorecard-tests/demo-scorecard-tests images/demo-scorecard-tests/cmd/test/main.go
	cd images/demo-scorecard-tests && docker build -t $(IMAGE):dev .

runtests: ## run the scorecard tests
	#operator-sdk scorecard ./bundle --selector=suite=tekton --service-account=tekton-operator-tests --namespace=default
	#operator-sdk scorecard ./bundle --selector='suite=tekton,test=pipelinerunsuccess' --service-account=tekton-operator-tests --namespace=default --skip-cleanup
	operator-sdk scorecard ./bundle --selector='suite=tekton' --service-account=tekton-operator-tests --namespace=default --skip-cleanup --wait-time 90s
