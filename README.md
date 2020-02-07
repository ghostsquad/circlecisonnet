# Circle Sonnet
CircleCI Jsonnet Library

## Conventions

- `key_`: hidden fields meant to be used by client will be suffixed with a single underscore.
- `__key__`: hidden fields meant for library use only will have a double underscore prefix and suffix (similar to Python)


## Examples

To Update:

this requires jsonnet and gojsontoyaml

```bash
go get github.com/google/go-jsonnet/cmd/jsonnet
go get github.com/brancz/gojsontoyaml
```

```bash
jsonnet --jpath "." ./examples/orbs.jsonnet | gojsontoyaml > ./examples/orbs.yaml
jsonnet --jpath "." ./examples/bells-whistles.jsonnet | gojsontoyaml > ./examples/bells-whistles.yaml
jsonnet --jpath "." --jpath "./curated-templates" ./examples/build-test-deploy.jsonnet | gojsontoyaml > ./examples/build-test-deploy.yaml
```
