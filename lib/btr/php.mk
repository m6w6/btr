.PHONY: all
.SUFFIXES:

CONFIGS=$(wildcard $(BRANCH_DIR)/ext/*/config*.m4)

all: $(TEST_REPORT)
	TESTS_PASSED=$$(awk '/^Tests passed/{print $$4}' < $(TEST_REPORT)); \
	TESTS_FAILED=$$(awk '/^Tests failed/{print $$4}' < $(TEST_REPORT)); \
	if test -z "$(LAST_REPORT)"; then \
		printf "%d/%d\n" $$TESTS_PASSED $$TESTS_FAILED; \
	else \
		LAST_PASSED=$$(awk '/^Tests passed/{print $$4}' < $(LAST_REPORT)); \
		LAST_FAILED=$$(awk '/^Tests failed/{print $$4}' < $(LAST_REPORT)); \
		DIFF_PASSED=$$(bc <<<"$$TESTS_PASSED - $$LAST_PASSED"); \
		DIFF_FAILED=$$(bc <<<"$$TESTS_FAILED - $$LAST_FAILED"); \
		printf "+%d/+%d\n" $$DIFF_PASSED $$DIFF_FAILED; \
	fi;

$(TEST_REPORT): $(BUILD_REPORT)
	cd $(BUILD_DIR) && \
	make test TESTS=../$(BRANCH_DIR)/$(TESTS) > ../$@

$(BUILD_REPORT): $(CONFIG_REPORT)
	cd $(BUILD_DIR) && \
	make -j $(CPUS) > ../$@
	
$(CONFIG_REPORT): $(BRANCH_DIR)/configure $(BUILD_DIR)
	cd $(BUILD_DIR) && \
	../$(BRANCH_DIR)/configure -C $(CONFIGURE) > ../$@

$(BUILD_DIR):
	mkdir -p $@
	
$(BRANCH_DIR)/configure: $(BRANCH_DIR)/buildconf $(CONFIGS)
	cd $(BRANCH_DIR) && \
	./buildconf > /dev/null

# vim: set noet
