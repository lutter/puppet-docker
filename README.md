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

say this copy will not work due to root account disabled, you can try this:

	scp ./puppet-agent/puppet/bin/steal-keys-manually puppetmaster:~/
	ssh puppetmaster "bash steal.sh"
	scp -r puppetmaster:~/ssl/* puppet-agent/puppet/ssl/
	ssh puppetmaster "rm -rf ~/ssl/"

Since we are now using a dedicated SSL certificate for just this image
build, the `site.pp` can treat that certificate like any other host:

    node CERTNAME {
      # describe what should go into the container image
    }

## Running `puppet agent` during a Docker build
### Basic usage

The `puppet-agent/Dockerfile` shows how to run `puppet agent` while
building with Docker.

You should also edit `puppet-agent/puppet/config.yaml` and add whatever
custom facts you want to use to help in describing what goes into your
container image above.

Once you've done that, just run `docker build puppet-agent` as you usually
would.

### Advanced usage
If you want to use a puppetmaster that is not reachable as "puppet", but via an ip address
You can use this line to do that:

    RUN echo "IP_ADDRESS_OF_YOUR_PUPPETMASTER puppet" >> /etc/hosts \
	&& /tmp/puppet-docker/bin/puppet-docker; \
	echo $?; \
	if [ $? -eq 1 ]; then exit 0; fi; exit $?

This line will also help you tackle problems where the puppet agent will exit with value 1,
puppet is a bit weird whereby an exit with value 1 means: all changes successfull. 

This is a problem because exiting with a !0 value will break your Docker build.

## Working around the cache of Docker

Say you are in a situation where you have succeffully build a docker image, and later you 
changed some puppet code that has to be included in your docker image. 

If you simply run "docker build ." again, puppet will not run because the command itself did not change.
This mechanism is normally one of the avantages of Docker, and is called caching.

To actually trigger a full puppet run you should remove this caching, you can do that by creating an
empty file called foo.txt or cachebuster.txt, including it in your Dockerfile BEFORE the puppetrun
and setting a new string in this file every time you do a "docker build ."

Example:

    echo $(date) > cachebuster.txt

And now add this file BEFORE your puppetrun command in your Dockerfile

    ADD cacheremover.txt /tmp/cacheremover.txt

Docker will now thinks that some of the dependencies (the txt file) of the command (the puppetrun)
will have changed and therefore it is unsafe to use the cache of the command of the previous build.

Docker will then continue to remove the cache, and trigger a new run of the command, resulting in a
new puppetrun.

It is strongly adviced to have these steps as late as possible in your Dockerfile, so that Docker
can cache as much steps as possible (like installing puppet, or adding files etc)
