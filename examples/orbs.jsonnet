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
        .withDockerImage("debian:buster")
        .withStep(c.steps.checkout())
        .withOrbStep(orbs.docker.steps.build + {
            // https://circleci.com/orbs/registry/orb/circleci/docker#commands-build
            params:: {
                image: "example",
                debug: true
            },
        }),

    hadolint: orbs.docker.jobs.hadolint
};

c.configYaml('orbs-example')
    .withWorkflow()
    .withJob(jobs.hadolint)
    .withJob(jobs.dockerBuild)