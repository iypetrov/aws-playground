run-local:
	@docker build -f Dockerfile.local -t foo:test .
	@docker run -p 9000:8080 foo:test

invoke-local:
	curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" \
	-H "Content-Type: application/json" \
	-d '{ \
		"key": "foo", \
		"value": "bar" \
	}'

build-and-push:
	@docker buildx build --platform linux/amd64 --builder mybuilder -t 678468774710.dkr.ecr.eu-west-2.amazonaws.com/playground/foo:test --push .
	@aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 678468774710.dkr.ecr.eu-west-2.amazonaws.com
	@docker tag playground/foo:test 678468774710.dkr.ecr.eu-west-2.amazonaws.com/playground/foo:test
	@docker push 678468774710.dkr.ecr.eu-west-2.amazonaws.com/playground/foo:test

fmt:
	@go fmt $(shell go list ./... | grep -v /vendor/)
	@find . -path ./vendor -prune -o -name '*.go' -exec goimports -l -w {} +

update-deps:
	@go mod tidy
	@go get -u
	@go mod vendor

vuln-check:
	@govulncheck -show verbose ./...

