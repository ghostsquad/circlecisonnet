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

    hadolint: orbs.docker.jobs.hadolint,
    hello: c.job("hello")
        .withStep(
            c.steps.run() {
                command_:: 'echo "hello world"'
            },
        ),
    goodbye: c.job("goodbye")
        .withStep(
            c.steps.run() {
                command_:: 'echo "goodbye world"'
            },
        ),
};

c.configYaml('orbs-example')
    .withWorkflow()
    .withJob(jobs.hello)
    .withJob(jobs.hadolint + {
        requires_: jobs.hello,
    })
    .withJob(jobs.dockerBuild + {
        requires_: [ jobs.hello, jobs.hadolint, ]
    })
    .withJob(jobs.goodbye + {
        requires_: [ jobs.hadolint, jobs.dockerBuild],
    })