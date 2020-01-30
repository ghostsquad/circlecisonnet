local c = import "circle.libsonnet";

local orbs = {
    docker: c.orb("docker") {
        publisher_: "circleci",
        name_: "docker",
        version_: "0.5.20"
    }.withJob("hadolint")
    .withStep("build")
};

local jobs = {
    dockerBuild: c.job("docker-build-only")
        .withStep(c.steps.checkout())
        .withOrbStep(orbs.docker.steps_.build + {
            // https://circleci.com/orbs/registry/orb/circleci/docker#commands-build
            params_:: {
                debug: true
            },
        }),

    hadolint: orbs.jobs.hadolint
};

c.configYaml('orbs-example')
    .withWorkflow()
    .withJob(jobs.dockerBuild)