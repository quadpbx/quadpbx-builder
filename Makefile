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

# List of commands we just hand off to the pbx-iso-builder package
PASSTHROUGH=splash reiso iso biostest test

.PHONY: $(PASSTHROUGH)
$(PASSTHROUGH):
	@echo Passing command $@ to pbx-iso-builder
	@cd $(ISOBUILDER); $(MAKE) $@


