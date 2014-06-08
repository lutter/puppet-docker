## -*- docker-image-name: "lutter:puppet-agent" -*-
FROM fedora:20
MAINTAINER David Lutterkort <lutter@watzmann.net>

ADD puppet /tmp/puppet-docker
RUN yum -y localinstall \
      http://yum.puppetlabs.com/puppetlabs-release-fedora-20.noarch.rpm; \
    yum -y install puppet; \
    yum clean all; \
    /tmp/puppet-docker/bin/puppet-docker
