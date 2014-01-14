BTR_SOURCE_CLEAN=false

.PHONY: all clean
.SUFFIXES:

all: $(BTR_BRANCH_DIR) clean
	$(SAY) "Updating $(BTR_BRANCH)..."
	cd $(BTR_BRANCH_DIR) && \
		svn update $(BTR_QUIET_FLAG);

clean: $(BTR_BRANCH_DIR)
	if $(BTR_SOURCE_CLEAN); \
	then \
		cd $(BTR_BRANCH_DIR) && \
			svn revert $(BTR_QUIET_FLAG); \
	fi;

$(BTR_BRANCH_DIR):
	$(SAY) "Performing checkout from $(BTR_SOURCE_ARGS)..."
	svn checkout $(BTR_QUIET_FLAG) $(BTR_SOURCE_ARGS)/$(BTR_BRANCH) $(BTR_BRANCH_DIR)

# vim: noet
