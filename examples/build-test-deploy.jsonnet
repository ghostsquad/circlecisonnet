// this jsonnet file is based on a pipeline template
// it demonstrates the ability to create reusable "curated" templates
// for different teams and projects with minimal configuration/code per project
// imagine this file being in the project repo, and using the curated template as an external library

local t = (import "build-test-deploy.libsonnet") + {
    params+: {
        name: "the-big-tamale",
    },
};

t.workflow()