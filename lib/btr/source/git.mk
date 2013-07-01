.PHONY: pull all
.SUFFIXES:

all: $(BRANCH_DIR) pull
	cd $(BRANCH_DIR) && \
	git pull -q

pull: $(CLEAN_DIR)
	cd $(CLEAN_DIR) && \
	git pull -q

$(CLEAN_DIR):
	git clone -q $(SOURCE_URL) $(CLEAN_DIR)

$(BRANCH_DIR): $(CLEAN_DIR)
	git-new-workdir $(CLEAN_DIR) $(BRANCH_DIR) $(BRANCH)

# vim: noet
