SHELL=/bin/bash
BUILDROOT=$(shell pwd)
ISOBUILDER=$(BUILDROOT)/pbx-iso-builder

THEME=quadpbx
THEMEDIR=$(BUILDROOT)/quadpbx-theme
export THEME THEMEDIR

# Build number and branch of the ISO, used for versioning
BRANCH=$(shell date +%Y.%m)
export BRANCH
# This is where the build tags are kept, used by buildnum.sh
BUILDREF=$(BUILDROOT)/.builds
export BUILDREF

BUILDNUM=$(shell $(ISOBUILDER)/buildnum.sh $(BRANCH))
BUILDTAG=$(BRANCH)-$(shell printf "%03d" $(BUILDNUM))

# This is where virtio will put its packages, instead of
# inside pbx-iso-builder/packages
VFSDIR=$(shell pwd)/packages
export VFSDIR

# List of commands we just hand off to the pbx-iso-builder package
PASSTHROUGH=splash reiso iso

.PHONY: $(PASSTHROUGH)
$(PASSTHROUGH):
	@echo Passing command $@ to pbx-iso-builder
	@cd $(ISOBUILDER); $(MAKE) -s $@

# Noisy passthrough (no -s on make)
NPASSTHROUGH=biostest test
.PHONY: $(NPASSTHROUGH)
$(NPASSTHROUGH):
	@echo Passing command $@ to pbx-iso-builder
	@cd $(ISOBUILDER); $(MAKE) $@
