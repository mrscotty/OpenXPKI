# Run ogflow
#
# Usage:
#
#   cd ~/git/openxpki
#   make -f core/server/t/60_workflow/07_ogflow.mk
#   

FULLPERLRUN := $(shell which perl)
TEST_VERBOSE := 0

# Base directory containing test script and config dir
basedir := core/server/t/60_workflow

# Destination directory for the workflow XML files
xmldir := $(basedir)/07_ogflow.d

graffledir := core/config/graffle
ogflow := tools/scripts/ogflow.pl
ogflowopts :=
#ogflowopts := --verbose

workflows := ogflow

-include core/server/t/60_workflow/07_ogflow.mk.local

# Determine names of four individual workflow XML files
basenames := $(foreach file,$(workflows),workflow_def_$(file) workflow_activity_$(file) workflow_condition_$(file) workflow_validator_$(file))

# Prepend the full file path of the host-specific files and add .xml extension
xmls := $(foreach file,$(basenames),$(xmldir)/$(file).xml)

# Test Files - short name of files, relative to core/server directory
TEST_FILES := t/60_workflow/07_ogflow.t

.PHONY: all
all: $(xmls)

test: $(xmls)
	(cd core/server && \
		PERL_DL_NONLAZY=1 $(FULLPERLRUN) \
		-I . \
		"-MExtUtils::Command::MM" "-e" "test_harness($($TEST_VERBOSE))" \
		$(TEST_FILES))

.PHONY: clean
clean:
	rm -f $(xmls)

.PHONY: debug
debug:
	@echo "xmls := $(xmls)"

# Create the XML files
	
$(xmldir)/workflow_def_%.xml: $(graffledir)/workflow_%.graffle $(ogflow)
	$(ogflow) $(ogflowopts) --outtype=states --outfile="$@" --infile="$<"

$(xmldir)/workflow_activity_%.xml: $(graffledir)/workflow_%.graffle $(ogflow)
	$(ogflow) $(ogflowopts) --outtype=actions --outfile="$@" --infile="$<"

$(xmldir)/workflow_condition_%.xml: $(graffledir)/workflow_%.graffle $(ogflow)
	$(ogflow) $(ogflowopts) --outtype=conditions --outfile="$@" --infile="$<"

$(xmldir)/workflow_validator_%.xml: $(graffledir)/workflow_%.graffle $(ogflow)
	$(ogflow) $(ogflowopts) --outtype=validators --outfile="$@" --infile="$<"

