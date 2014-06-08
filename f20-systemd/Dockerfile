## -*- docker-image-name: "lutter:f20-systemd" -*-

# Set up systemd to run inside a container
# From http://developerblog.redhat.com/2014/05/05/running-systemd-within-docker-container/
# We also install sshd and enable it
# TODO: This whole thing should become a Puppet manifest

#
# To test this container, run
#   docker run --privileged -ti --rm -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 2223:22 --name sd lutter:f20-systemd /bin/bash
#
# To run for reals
#   docker run --privileged --rm -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 2223:22 --name sd lutter:f20-systemd

FROM fedora:20
MAINTAINER David Lutterkort <lutter@watzmann.net>

ENV container docker

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]

# Now add in sshd
RUN yum -y install openssh-server; yum clean all; ln -sf /usr/lib/systemd/system/sshd.service /etc/systemd/system/multi-user.target.wants/sshd.service; chmod a-w,o-x /root


EXPOSE 22
CMD ["/usr/sbin/init"]
