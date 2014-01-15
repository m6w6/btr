BTR_BUILD_CLEAN=false
BTR_BUILD_ARGS=
BTR_TEST_ARGS=

.PHONY: all clean
.SUFFIXES:

CONFIGS=$(wildcard $(BTR_BRANCH_DIR)/configure.*)

all: clean $(BTR_REPORT)
	$(SAY) "Result: $$(cat $(BTR_REPORT))"

clean: $(BTR_CONFIG_REPORT)
	if $(BTR_BUILD_CLEAN); \
	then \
		cd $(BTR_BUILD_DIR) && \
			make $(BTR_SILENT_FLAG) clean; \
	fi;

$(BTR_REPORT): $(BTR_TEST_REPORT)
	( \
		if test -z "$(BTR_LAST_REPORT)"; then \
			echo 0; \
		elif test -s "$(BTR_LAST_REPORT)" -o -s "$(BTR_TEST_REPORT)"; then \
			cmp $(BTR_LAST_REPORT) $(BTR_TEST_REPORT) || true; \
		else \
			echo 0; \
		fi;
	) >$@ 2>&1

$(BTR_TEST_REPORT): $(BTR_BUILD_REPORT)
	$(SAY) "Running checks..."
	(cd $(BTR_BUILD_DIR) && \
		make check $(BTR_TEST_ARGS) \
	) >$@ 2>&1

$(BTR_BUILD_REPORT): $(BTR_CONFIG_REPORT)
	$(SAY) "Making build..."
	(cd $(BTR_BUILD_DIR) && \
		make -j $(CPUS) \
	) >$@ 2>&1
	
$(BTR_CONFIG_REPORT): $(BTR_BRANCH_DIR)/configure | $(BTR_BUILD_DIR) $(BTR_LOG_DIR)
	$(SAY) "Running configure..."
	(cd $(BTR_BUILD_DIR) && \
		../../$(BTR_BRANCH_DIR)/configure -C $(BTR_BUILD_ARGS) \
	) >$@ 2>&1

$(BTR_BUILD_DIR):
	mkdir -p $@

$(BTR_LOG_DIR):
	mkdir -p $@

$(BTR_BRANCH_DIR)/configure: $(CONFIGS)
	$(SAY) "Building configure..."
	cd $(BTR_BRANCH_DIR) && \
		autoreconf -i -f -W none >/dev/null

# vim: noet
