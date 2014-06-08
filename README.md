# Experiments with Docker and Puppet

This repository contains some files that might be helpful when using Puppet
during the Docker image building process. In particular, they show how to
run `puppet agent` during a Docker build.

## Running `puppet` agent during a Docker build

The `puppet-agent/Dockerfile` shows how to run `puppet agent` while
building with Docker. Before using that, you will want to steal SSL keys
from a Puppet agent and put them into `puppet-agent/puppet/ssl` - you can
use the `steal-keys` script like so:

    ./puppet-agent/puppet/bin/steal-keys HOSTNAME

where `HOSTNAME` is the name of the Puppet client whose keys you are going
to use during the build. In your `site.pp` (or equivalent) you'll also want
to have something like

    node HOSTNAME {
      if ($container == 'docker' && $build == 'true') {
        # describe what should go into the container image
      } else {
        # describe what should go onto HOSTNAME proper
      }
    }

You should also edit `puppet-agent/puppet/config.yaml` and add whatever
custom facts you want to use to help in describing what goes into your
container image above.

Once you've done that, just run `docker build puppet-agent` as you usually
would.
