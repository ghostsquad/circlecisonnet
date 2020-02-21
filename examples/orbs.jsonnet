local c = import "circleci.libsonnet";

local orbs = {
    docker: c.orb("docker") {
        publisher: "circleci",
        name: "docker",
        version: "0.5.20"
    }.withJob("hadolint")
    .withStep("build")
};

local jobs = {
    dockerBuild: c.job("docker-build-only")
        .withStep(c.steps.checkout())
        .withOrbStep(orbs.docker.steps.build + {
            // https://circleci.com/orbs/registry/orb/circleci/docker#commands-build
            params:: {
                debug: true
            },
        }),

    hadolint: orbs.jobs.hadolint
};

c.configYaml('orbs-example')
    .withWorkflow()
    .withJob(jobs.dockerBuild)