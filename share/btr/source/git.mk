BTR_SOURCE_CLEAN=false

.PHONY: fetch all clean
.SUFFIXES:

all: $(BTR_BRANCH_DIR) clean fetch
	$(SAY) "Merging $(BTR_BRANCH) of $(BTR_REPO)..."
	cd $(BTR_BRANCH_DIR) && \
		git merge $(BTR_QUIET_FLAG) --ff-only;

clean: $(BTR_BRANCH_DIR)
	if $(BTR_SOURCE_CLEAN); \
	then \
		cd $(BTR_BRANCH_DIR) && \
			git reset --hard $(BTR_QUIET_FLAGS); \
	fi;

fetch: $(BTR_REPO_DIR)
	$(SAY) "Fetching $(BTR_REPO)..."
	cd $(BTR_REPO_DIR) && \
		git fetch $(BTR_QUIET_FLAG);

$(BTR_REPO_DIR):
	$(SAY) "Cloning from $(BTR_SOURCE_ARGS)..."
	git clone $(BTR_QUIET_FLAG) $(BTR_SOURCE_ARGS) $(BTR_REPO_DIR);

$(BTR_BRANCH_DIR): $(BTR_REPO_DIR)
	$(SAY) "Creating workdir for $(BTR_BRANCH)"
	git-new-workdir $(BTR_REPO_DIR) $(BTR_BRANCH_DIR) $(BTR_BRANCH)

# vim: noet
