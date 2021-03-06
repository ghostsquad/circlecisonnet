{
    mapToArray(o):: [ { [field]: o[field] } for field in std.objectFields(o) ],

    strContains(s, substr):: (
        std.length(std.findSubstr(substr, s)) > 0
    ),

    orb(id):: {
        local orb = self,
        id:: id,

        publisher:: error "publisher_ required",
        name:: error "name_ required",
        version:: error "version_ required",
        fullName:: "%s/%s@%s" % [self.publisher, self.name, self.version],

        jobs:: {},
        steps:: {},

        __refMixin__:: {
            ref:: "%s/%s" % [orb.id, self.__name__],
            parentOrb:: orb,
            orbs:: [orb],
        },

        withJob(name, params = {}):: self + {
            jobs+:: {
                [name]:: orb.__refMixin__ + {
                    __name__:: name,
                    name:: self.ref,
                    params:: {},
                    __asWorkflow__(): self.params,
                },
            },
        },

        withStep(name, params = {},):: self + {
            steps+:: {
                [name]:: orb.__refMixin__ + {
                    __name__:: name,
                    name:: name,
                    params:: {},
                },
            },
        },
    },

    whenStepModifier:: {
        always:: "always",
        onSuccess:: "on_success",
        onFail:: "on_fail",
    },

    steps:: {
        run():: {
            local step = self,

            name_:: null,
            command_:: error "command_ required",
            shell_:: null,
            environment_:: {},
            background_:: null,
            workingDirectory_:: null,
            noOutputTimeout_:: null,
            when_:: null,

            run: {
                [if step.name_ == null then null else "name"]: step.name_,
                command: step.command_,
                [if step.shell_ == null then null else "shell"]: step.shell_,
                [if std.length(step.environment_) == 0 then null else "environment"]: step.environment_,
                [if step.background_ == null then null else "background"]: step.background_,
                [if step.workingDirectory_ == null then null else "working_directory"]: step.workingDirectory_,
                [if step.noOutputTimeout_ == null then null else "no_output_timeout"]: step.noOutputTimeout_,
                [if step.when_ == null then null else "when"]: step.when_,
            },
        },
        when():: {
            local step = self,
            condition_:: error "condition_ required",
            steps_:: error "steps_ required",

            when: {
                condition: step.condition_,
                steps: step.steps_,
            },
        },
        unless():: {
            local step = self,
            condition_:: error "condition_ required",
            steps_:: error "steps_ required",

            unless: {
                condition: step.condition_,
                steps: step.steps_,
            },
        },
        checkout():: {
            local step = self,
            path_:: null,
            checkout: {
                [if step.path_ == null then null else "path"]: step.path_,
            },
        },
        setupRemoteDocker():: {
            local step = self,
            dockerLayerCaching_:: null,
            version_:: null,

            setup_remote_docker: {
                [if step.dockerLayerCaching_ == null then null else "docker_layer_caching"]: step.dockerLayerCaching_,
                [if step.version_ == null then null else "version"]: step.version_,
            },
        },
        saveCache():: {
            local step = self,

            paths_:: error "paths_ required",
            key_:: error "key_ required",
            name_:: null,
            when_:: null,

            save_cache: {
                paths: step.paths_,
                key: step.key_,
                [if step.name_ == null then null else "name"]: step.name_,
                [if step.when_ == null then null else "when"]: step.when_,
            },
        },
        restoreCache():: {
            local step = self,

            keys_:: error "keys_ required",
            name_:: null,

            restore_cache: {
                keys: step.keys_,
                [if step.name_ == null then null else "name"]: step.name_,
            },
        },
        deploy():: error "not implemented",
        storeArtifacts():: {
            local step = self,

            path_:: error "path_ required",
            destination_:: null,

            store_artifacts: {
                path: step.path_,
                [if step.destination_ == null then null else "destination"]: step.destination_,
            },
        },

        storeTestResults():: {
            local step = self,

            path_:: error "path_ required",

            store_test_results: {
                path: step.path_,
            },
        },
        persistToWorkspace():: {
            local step = self,

            root_:: error "root_ required",
            paths_:: error "paths_ required",

            persist_to_workspace: {
                root: step.root_,
                paths: step.paths,
            },
        },
        attachWorkspace():: {
            local step = self,

            at_:: error "at_ required",

            attach_workspace: {
                at: step.at_,
            },
        },
        addSshKeys():: error "not implemented"
    },

    job(name):: {
        local this = self,

        name:: name,
        requires_:: null,
        filters_:: null,
        orbs:: [],
        steps:: [],
        dockerImage:: error "dockerImage required",
        environment:: {},

        withDockerImage(image):: self + {
            dockerImage:: image
        },
        withEnvironmentVars(vars):: self + {
            environment:: vars,
        },
        withStep(step):: self + {
            steps+:: [step],
        },
        withOrbStep(step):: self + {
            steps+:: [
                {
                    [step.ref]: step.params
                }
            ],
        },
        __asTopLevel__():: {
            steps: this.steps,
            [if this.dockerImage == null then null else "docker"]: [
                {
                    image: this.dockerImage,
                    [if std.length(this.environment) == 0 then null else "environment"]: this.environment,
                    [if $.strContains(this.dockerImage, "dkr.ecr")  then "auth" else null]: {
                        aws_access_key_id: "$ECR_AWS_ACCESS_KEY_ID",
                        aws_secret_access_key: "$ECR_AWS_SECRET_ACCESS_KEY",
                    },
                },
            ],
        },
        __asWorkflow__():: {
            [if this.requires_ == null then null else "requires"]: 
                if std.type(this.requires_) == "string"
                then [this.requires_]
                else if std.type(this.requires_) == "object"
                then [this.requires_.name]
                else if std.type(this.requires_) == "array"
                then [ if std.type(i) == "string" then i else i.name for i in this.requires_ ]
                else error "expected requires_ to be a string, object or array, got %s" % std.type(this.requires_),
            [if this.filters_ == null then null else "filters"]: this.filters_,
        },
    },

    configYaml(name):: {
        local configYaml = self,

        name:: name,
        workspaceRoot:: "/var/circleci",

        version: "2.1",
        jobs: {},
        orbs: {},
        workflows: {},

        withWorkflow(name = null):: self + {
            local nameResolved = if name != null then name else configYaml.name,
            workflows+: {
                [nameResolved]+: {
                    name:: nameResolved,
                    jobs_:: {},
                    jobs: $.mapToArray(self.jobs_)
                },
            },
            withJob(j):: self + {
                jobs+: {
                    [if std.objectHasAll(j, "__asTopLevel__") then j.name else null]: j.__asTopLevel__(),
                },
                orbs+: { [i.id]: i.fullName for i in j.orbs },
                workflows+: {
                    [nameResolved]+: {
                        jobs_+:: {
                            [j.name]: j.__asWorkflow__()
                        },
                    },
                },
            },
            withTrigger(t):: self + {
                workflows+: {
                    [nameResolved]+: {
                        triggers+: [t], 
                    },
                },
            },
        },
    },
}