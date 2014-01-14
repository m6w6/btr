BTR_SOURCE_CLEAN=false
CVSROOT=$(shell cut -d'\#' -f1 <<<$(BTR_SOURCE_ARGS))
CVS_MOD=$(shell cut -d'\#' -f2 -s <<<$(BTR_SOURCE_ARGS))
CVS_RSH=ssh

export

ifeq ($(value BTR_QUIET_FLAG), -q)
override BTR_QUIET_FLAG = -Q
endif

.PHONY: all clean login
.SUFFIXES:

all: $(BTR_BRANCH_DIR) clean
	$(SAY) "Updating $(BTR_BRANCH)..."
	cd $(BTR_BRANCH_DIR) && \
		cvs $(BTR_QUIET_FLAG) -z3 update -RPd;

clean: $(BTR_BRANCH_DIR)
	if $(BTR_SOURCE_CLEAN); \
	then \
		cd $(BTR_BRANCH_DIR) && \
			cvs $(BTR_QUIET_FLAG) -z3 update -CRPd; \
	fi;

$(BTR_BRANCH_DIR):
	$(SAY) "Performing checkout of $(CVS_MOD) from $(CVSROOT)..."
	cvs $(BTR_QUIET_FLAG) checkout -RP -r $(BTR_BRANCH) -d $(BTR_BRANCH_DIR) $(CVS_MOD)

# vim: noet
