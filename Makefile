.PHONY: %

render.examples.orbs:
	jsonnet --jpath "." ./examples/orbs.jsonnet | gojsontoyaml > ./examples/orbs.yaml
	circleci config validate ./examples/orbs.yaml

render.examples.bells:
	jsonnet --jpath "." ./examples/bells-whistles.jsonnet | gojsontoyaml > ./examples/bells-whistles.yaml
	circleci config validate ./examples/bells-whistles.yaml

render.examples.curated:
	jsonnet --jpath "." --jpath "./curated-templates" ./examples/build-test-deploy.jsonnet | gojsontoyaml > ./examples/build-test-deploy.yaml
	circleci config validate ./examples/build-test-deploy.yaml
