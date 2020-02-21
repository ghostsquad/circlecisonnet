# Circle Sonnet
CircleCI Jsonnet Library

## Conventions

- `key_`: hidden fields used to dynamically create exported fields of the same name will be suffixed with a single underscore.
- `__key__`: hidden fields meant for library use only will have a double underscore prefix and suffix (similar to Python)


## Examples

To Update:

this requires jsonnet and gojsontoyaml

```bash
go get github.com/google/go-jsonnet/cmd/jsonnet
go get github.com/brancz/gojsontoyaml
```

```bash
make render.examples.orbs
make render.examples.bells
make render.examples.curated
```
