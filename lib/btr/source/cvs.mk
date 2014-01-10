SOURCE_CLEAN=false
CVSROOT=$(shell cut -d'\#' -f1 <<<$(SOURCE_ARGS))
CVS_MOD=$(shell cut -d'\#' -f2 -s <<<$(SOURCE_ARGS))
CVS_RSH=ssh

export

ifeq ($(value QUIET_FLAG), -q)
override QUIET_FLAG = -Q
endif

.PHONY: all clean login
.SUFFIXES:

all: $(BRANCH_DIR) clean
	$(SAY) "Updating $(BRANCH)..."
	cd $(BRANCH_DIR) && \
		cvs $(QUIET_FLAG) -z3 update -RPd;

clean: $(BRANCH_DIR)
	if $(SOURCE_CLEAN); \
	then \
		cd $(BRANCH_DIR) && \
			cvs $(QUIET_FLAG) -z3 update -CRPd; \
	fi;

$(BRANCH_DIR):
	$(SAY) "Performing checkout of $(CVS_MOD) from $(CVSROOT)..."
	cvs $(QUIET_FLAG) checkout -RP -r $(BRANCH) -d $(BRANCH_DIR) $(CVS_MOD)

# vim: noet
