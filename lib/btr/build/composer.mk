BUILD_CLEAN=false
BUILD_ARGS= install --dev
TEST_ARGS= --strict --coverage-text

.PHONY: all clean
.SUFFIXES:

all: clean $(REPORT)
	$(SAY) "Result: $$(cat $(REPORT))"

clean: $(CONFIG_REPORT)
	if $(BUILD_CLEAN); \
	then \
		cd $(BUILD_DIR) && \
			rm -rf vendor; \
	fi;

$(REPORT): $(TEST_REPORT)
	@( \
		TESTS_PASSED=$$(grep -Pc '^ok \d+' < $(TEST_REPORT)); \
		TESTS_FAILED=$$(grep -Pc '^not ok \d+' < $(TEST_REPORT)); \
		\
		printf "%d/%d" $$TESTS_PASSED $$TESTS_FAILED >$@; \
		if test -s "$(LAST_REPORT)"; then \
			LAST_PASSED=$$(grep -Pc '^ok \d+' < $(LAST_REPORT)); \
			LAST_FAILED=$$(grep -Pc '^not ok \d+' < $(LAST_REPORT)); \
			DIFF_PASSED=$$(bc <<<"$$TESTS_PASSED - $$LAST_PASSED"); \
			DIFF_FAILED=$$(bc <<<"$$TESTS_FAILED - $$LAST_FAILED"); \
			printf " %+d/%+d" $$DIFF_PASSED $$DIFF_FAILED >>$@; \
		fi; \
		printf "\n" >>$@; \
	)

$(TEST_REPORT): $(BUILD_REPORT)
	$(SAY) "Running unit tests..."
	cd $(BUILD_DIR) && \
		phpunit --tap $(TEST_ARGS) . >../$@

$(BUILD_REPORT): $(CONFIG_REPORT) $(BUILD_DIR)/composer.lock
	$(SAY) "Installing dependencies..."
	cd $(BUILD_DIR) && \
		./composer.phar -n --no-ansi $(QUIET_FLAG) $(VERBOSE_FLAG) $(BUILD_ARGS) \
			>../$@

$(CONFIG_REPORT): $(BUILD_DIR)/composer.json $(BUILD_DIR)/composer.phar 
	touch $(CONFIG_REPORT)

$(BUILD_DIR)/composer.phar:
	$(SAY) "Orchestrating composer..."
	@cd $(BUILD_DIR) && ( \
		COMPOSER=$$(command -v composer); \
		if test $$? -eq 0; \
		then \
			ln -s $$COMPOSER composer.phar; \
		else \
			curl $(SILENT_FLAG) -S http://getcomposer.org/installer | php; \
		fi; \
	) >>$(CONFIG_REPORT)

$(BUILD_DIR)/composer.json: $(BRANCH_DIR)/composer.json
	rsync $(QUIET_FLAG) $(VERBOSE_FLAG) -a --delete $(BRANCH_DIR)/ $(BUILD_DIR)/ \
		>> $(CONFIG_REPORT)

$(BUILD_DIR)/composer.lock: $(BUILD_DIR)/composer.json $(BUILD_DIR)/composer.phar

# vim: noet
