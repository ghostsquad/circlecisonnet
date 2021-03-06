local c = import "circleci.libsonnet";

{
    params:: {
        name: error "name required",
    },

    jobs:: {
        dockerBuild: c.job("docker-build-only")
            .withDockerImage("circleci/buildpack-deps:buster-dind")
            .withStep(c.steps.checkout())
            .withOrbStep($.orbs.docker.steps.build + {
                // https://circleci.com/orbs/registry/orb/circleci/docker#commands-build
                params:: {
                    image: "example",
                    debug: true
                },
            }),

        hadolint: $.orbs.docker.jobs.hadolint,
        hello: c.job("hello")
            .withDockerImage("circleci/buildpack-deps:buster-dind")
            .withStep(
                c.steps.run() {
                    command_:: 'echo "hello %s"' % [$.params.name],
                },
            ),
        goodbye: c.job("goodbye")
            .withDockerImage("circleci/buildpack-deps:buster-dind")
            .withStep(
                c.steps.run() {
                    command_:: 'echo "goodbye %s"' % [$.params.name],
                },
            ),
    },

    orbs:: {
        docker: c.orb("docker") {
            publisher: "circleci",
            name: "docker",
            version: "0.5.20"
        }.withJob("hadolint")
        .withStep("build")
    },

    workflow():: c.configYaml($.params.name)
        .withWorkflow()
        .withJob($.jobs.hello)
        .withJob($.jobs.hadolint + {
            requires_: $.jobs.hello,
        })
        .withJob($.jobs.dockerBuild + {
            requires_: [ $.jobs.hello, $.jobs.hadolint, ]
        })
        .withJob($.jobs.goodbye + {
            requires_: [ $.jobs.hadolint, $.jobs.dockerBuild],
        })
}

