# The containers we want to build
#
# Each name must be the name of a subdirectory that contains a Dockerfile
# and supporting materials.
CONTAINERS=f20-systemd puppet-agent

all: $(CONTAINERS)

$(CONTAINERS): %:%/build.log

%/build.log: %/Dockerfile
	docker build -t lutter:$* $* > $@

fedora:
	docker pull fedora

# We really need containers to build in a specific order
.NOTPARALLEL:
