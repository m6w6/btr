.PHONY: all
.SUFFIXES:

all: $(BRANCH_DIR)
	cd $(BRANCH_DIR) && \
	svn update -q

$(BRANCH_DIR):
	svn checkout $(SOURCE_URL)/$(BRANCH) $(BRANCH_DIR)

# vim: set noet
