BTR_BUILD_CLEAN=false
BTR_BUILD_ARGS=
BTR_TEST_ARGS= -q

.PHONY: all clean
.SUFFIXES:

CONFIGS=$(wildcard $(BTR_BRANCH_DIR)/config*.m4 $(BTR_BRANCH_DIR)/*/config*.m4)

all: clean $(BTR_REPORT)
	$(SAY) "Result: $$(cat $(BTR_REPORT))"

clean: $(BTR_CONFIG_REPORT)
	if $(BTR_BUILD_CLEAN); \
	then \
		cd $(BTR_BUILD_DIR) && \
			make $(BTR_SILENT_FLAG) clean; \
	fi;

$(BTR_REPORT): $(BTR_TEST_REPORT)
	@(\
		TESTS_PASSED=$$(awk '/^Tests passed/{print $$4}' < $(BTR_TEST_REPORT)); \
		TESTS_FAILED=$$(awk '/^Tests failed/{print $$4}' < $(BTR_TEST_REPORT)); \
		printf "%d/%d" $$TESTS_PASSED $$TESTS_FAILED >$@; \
		if test -s "$(BTR_LAST_REPORT)"; then \
			LAST_PASSED=$$(awk '/^Tests passed/{print $$4}' < $(BTR_LAST_REPORT)); \
			LAST_FAILED=$$(awk '/^Tests failed/{print $$4}' < $(BTR_LAST_REPORT)); \
			DIFF_PASSED=$$(bc <<<"$$TESTS_PASSED - $$LAST_PASSED"); \
			DIFF_FAILED=$$(bc <<<"$$TESTS_FAILED - $$LAST_FAILED"); \
			printf " %+d/%+d" $$DIFF_PASSED $$DIFF_FAILED >>$@; \
		fi; \
		printf "\n" >>$@; \
	)

$(BTR_TEST_REPORT): $(BTR_BUILD_REPORT)
	$(SAY) "Running tests... "
	cd $(BTR_BUILD_DIR) && \
		make test TESTS="$(BTR_TEST_ARGS) -s ../../$@" >/dev/null

$(BTR_BUILD_REPORT): $(BTR_CONFIG_REPORT)
	$(SAY) "Making build..."
	(cd $(BTR_BUILD_DIR) && \
		make -j $(CPUS) \
	) >$@ 2>&1
	
$(BTR_CONFIG_REPORT): $(BTR_BRANCH_DIR)/configure | $(BTR_BUILD_DIR) $(BTR_LOG_DIR)
	$(SAY) "Running 'configure'..."
	(cd $(BTR_BUILD_DIR) && \
		../../$(BTR_BRANCH_DIR)/configure -C $(BTR_BUILD_ARGS) \
	) >$@ 2>&1

$(BTR_BUILD_DIR):
	mkdir -p $@

$(BTR_LOG_DIR):
	mkdir -p $@

$(BTR_BRANCH_DIR)/configure: $(CONFIGS)
	$(SAY) "Running phpize..."
	cd $(BTR_BRANCH_DIR) && \
		phpize >/dev/null

# vim: noet
