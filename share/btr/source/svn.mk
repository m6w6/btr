SOURCE_CLEAN=false

.PHONY: all clean
.SUFFIXES:

all: $(BRANCH_DIR) clean
	$(SAY) "Updating $(BRANCH)..."
	cd $(BRANCH_DIR) && \
		svn update $(QUIET_FLAG);

clean: $(BRANCH_DIR)
	if $(SOURCE_CLEAN); \
	then \
		cd $(BRANCH_DIR) && \
			svn revert $(QUIET_FLAG); \
	fi;

$(BRANCH_DIR):
	$(SAY) "Performing checkout from $(SOURCE_ARGS)..."
	svn checkout $(QUIET_FLAG) $(SOURCE_ARGS)/$(BRANCH) $(BRANCH_DIR)

# vim: noet
