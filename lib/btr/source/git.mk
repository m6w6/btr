SOURCE_CLEAN=false

.PHONY: fetch all clean
.SUFFIXES:

all: $(BRANCH_DIR) clean fetch
	$(SAY) "Merging $(BRANCH) of $(REPO)..."
	cd $(BRANCH_DIR) && \
		git merge $(QUIET_FLAG) --ff-only;

clean: $(BRANCH_DIR)
	if $(SOURCE_CLEAN); \
	then \
		cd $(BRANCH_DIR) && \
			git reset --hard $(QUIET_FLAGS); \
	fi;

fetch: $(CLEAN_DIR)
	$(SAY) "Fetching $(REPO)..."
	cd $(CLEAN_DIR) && \
		git fetch $(QUIET_FLAG);

$(CLEAN_DIR):
	$(SAY) "Cloning from $(SOURCE_ARGS)..."
	git clone $(QUIET_FLAG) $(SOURCE_ARGS) $(CLEAN_DIR);

$(BRANCH_DIR): $(CLEAN_DIR)
	$(SAY) "Creating workdir for $(BRANCH)"
	git-new-workdir $(CLEAN_DIR) $(BRANCH_DIR) $(BRANCH)

# vim: noet
