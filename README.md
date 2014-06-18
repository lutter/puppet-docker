# Experiments with Docker and Puppet

This repository contains some files that might be helpful when using Puppet
during the Docker image building process. In particular, they show how to
run `puppet agent` during a Docker build.

## Stealing keys

Before we can run the Puppet agent, we need to steal SSL keys from
somewhere: either from an existing client or, using pre-generated client
certificates, from the Puppet master

### Stealing from a client

The `steal-keys` script will do that:

    ./puppet-agent/puppet/bin/steal-keys HOSTNAME

where `HOSTNAME` is the name of the Puppet client whose keys you are going
to use during the build.

Since you are now using the same certificate for two different purposes ---
running a full Puppet client, and using the Puppet agent during image build
--- your `site.pp` will need to take that into account:

    node HOSTNAME {
      if ($container == 'docker' && $build == 'true') {
        # describe what should go into the container image
      } else {
        # describe what should go onto HOSTNAME proper
      }
    }

### Stealing from the Puppet master

You can pre-generate the needed certificates with

    puppet cert generate CERTNAME

where `CERTNAME` is the fake hostname you are going to use during image
building, and should be different from any legitimate hostname in your
infrastructure. The `steal-keys` script will then copy the SSL certificates
via ssh:

    ./puppet-agent/puppet/bin/steal-keys puppet CERTNAME

Since we are now using a dedicated SSL certificate for just this image
build, the `site.pp` can treat that certificate like any other host:

    node CERTNAME {
      # describe what should go into the container image
    }

## Running `puppet agent` during a Docker build

The `puppet-agent/Dockerfile` shows how to run `puppet agent` while
building with Docker.

You should also edit `puppet-agent/puppet/config.yaml` and add whatever
custom facts you want to use to help in describing what goes into your
container image above.

Once you've done that, just run `docker build puppet-agent` as you usually
would.
