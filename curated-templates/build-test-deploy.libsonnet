local c = import "circle.libsonnet";

{
    params:: {
        name: error "name required",
    },

    local jobs = {
        dockerBuild: c.job("docker-build-only")
            .withStep(c.steps.checkout())
            .withOrbStep(orbs.docker.steps_.build + {
                // https://circleci.com/orbs/registry/orb/circleci/docker#commands-build
                params_:: {
                    debug: true
                },
            }),

        hadolint: orbs.docker.jobs_.hadolint,
        hello: c.job("hello")
            .withStep(
                c.steps.run() {
                    command_:: 'echo "hello %s"' % [$.params.name],
                },
            ),
        goodbye: c.job("goodbye")
            .withStep(
                c.steps.run() {
                    command_:: 'echo "goodbye %s"' % [$.params.name],
                },
            ),
    },

    local orbs = {
        docker: c.orb("docker") {
            publisher_: "circleci",
            name_: "docker",
            version_: "0.5.20"
        }.withJob("hadolint")
        .withStep("build")
    },

    workflow():: c.configYaml($.params.name)
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
}

