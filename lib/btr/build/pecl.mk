BUILD_CLEAN=false
BUILD_ARGS=
TEST_ARGS= -q

.PHONY: all clean
.SUFFIXES:

CONFIGS=$(wildcard $(BRANCH_DIR)/config*.m4 $(BRANCH_DIR)/*/config*.m4)

all: clean $(REPORT)
	$(SAY) "Result: $$(cat $(REPORT))"

clean: $(CONFIG_REPORT)
	if $(BUILD_CLEAN); \
	then \
		cd $(BUILD_DIR) && \
			make $(SILENT_FLAG) clean; \
	fi;

$(REPORT): $(TEST_REPORT)
	@(\
		TESTS_PASSED=$$(awk '/^Tests passed/{print $$4}' < $(TEST_REPORT)); \
		TESTS_FAILED=$$(awk '/^Tests failed/{print $$4}' < $(TEST_REPORT)); \
		printf "%d/%d" $$TESTS_PASSED $$TESTS_FAILED >$@; \
		if test -s "$(LAST_REPORT)"; then \
			LAST_PASSED=$$(awk '/^Tests passed/{print $$4}' < $(LAST_REPORT)); \
			LAST_FAILED=$$(awk '/^Tests failed/{print $$4}' < $(LAST_REPORT)); \
			DIFF_PASSED=$$(bc <<<"$$TESTS_PASSED - $$LAST_PASSED"); \
			DIFF_FAILED=$$(bc <<<"$$TESTS_FAILED - $$LAST_FAILED"); \
			printf " %+d/%+d" $$DIFF_PASSED $$DIFF_FAILED >>$@; \
		fi; \
		printf "\n" >>$@; \
	)

$(TEST_REPORT): $(BUILD_REPORT)
	$(SAY) "Running tests... "
	cd $(BUILD_DIR) && \
		make test TESTS="$(TEST_ARGS) -s ../$@" >/dev/null

$(BUILD_REPORT): $(CONFIG_REPORT)
	$(SAY) "Making build..."
	cd $(BUILD_DIR) && \
		make -j $(CPUS) >../$@ 2>&1
	
$(CONFIG_REPORT): $(BRANCH_DIR)/configure $(BUILD_DIR)
	$(SAY) "Running 'configure'..."
	cd $(BUILD_DIR) && \
		../$(BRANCH_DIR)/configure -C $(BUILD_ARGS) >../$@ 2>&1

$(BUILD_DIR):
	mkdir -p $@
	
$(BRANCH_DIR)/configure: $(CONFIGS)
	$(SAY) "Running phpize..."
	cd $(BRANCH_DIR) && \
		phpize >/dev/null

# vim: noet
