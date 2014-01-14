BTR_BUILD_CLEAN=false
BTR_BUILD_ARGS= install --dev
BTR_TEST_ARGS= --strict --coverage-text

.PHONY: all clean
.SUFFIXES:

all: clean $(BTR_REPORT)
	$(SAY) "Result: $$(cat $(BTR_REPORT))"

clean: $(BTR_CONFIG_REPORT)
	if $(BTR_BUILD_CLEAN); \
	then \
		cd $(BTR_BUILD_DIR) && \
			rm -rf vendor; \
	fi;

$(BTR_REPORT): $(BTR_TEST_REPORT)
	@( \
		TESTS_PASSED=$$(grep -Pc '^ok \d+' < $(BTR_TEST_REPORT)); \
		TESTS_FAILED=$$(grep -Pc '^not ok \d+' < $(BTR_TEST_REPORT)); \
		\
		printf "%d/%d" $$TESTS_PASSED $$TESTS_FAILED >$@; \
		if test -s "$(BTR_LAST_REPORT)"; then \
			LAST_PASSED=$$(grep -Pc '^ok \d+' < $(BTR_LAST_REPORT)); \
			LAST_FAILED=$$(grep -Pc '^not ok \d+' < $(BTR_LAST_REPORT)); \
			DIFF_PASSED=$$(bc <<<"$$TESTS_PASSED - $$LAST_PASSED"); \
			DIFF_FAILED=$$(bc <<<"$$TESTS_FAILED - $$LAST_FAILED"); \
			printf " %+d/%+d" $$DIFF_PASSED $$DIFF_FAILED >>$@; \
		fi; \
		printf "\n" >>$@; \
	)

$(BTR_TEST_REPORT): $(BTR_BUILD_REPORT)
	$(SAY) "Running unit tests..."
	(cd $(BTR_BUILD_DIR) && \
		phpunit --tap $(BTR_TEST_ARGS) . \
	) >$@

$(BTR_BUILD_REPORT): $(BTR_CONFIG_REPORT) $(BTR_BUILD_DIR)/composer.lock
	$(SAY) "Installing dependencies..."
	(cd $(BTR_BUILD_DIR) && \
		./composer.phar -n --no-ansi $(BTR_QUIET_FLAG) $(BTR_VERBOSE_FLAG) $(BTR_BUILD_ARGS) \
	) >$@

$(BTR_CONFIG_REPORT): $(BTR_BUILD_DIR)/composer.json $(BTR_BUILD_DIR)/composer.phar | $(BTR_LOG_DIR)
	touch $@

$(BTR_BUILD_DIR):
	mkdir -p $@

$(BTR_LOG_DIR):
	mkdir -p $@

$(BTR_BUILD_DIR)/composer.phar: | $(BTR_BUILD_DIR) $(BTR_LOG_DIR)
	$(SAY) "Orchestrating composer..."
	(cd $(BTR_BUILD_DIR) && \
		COMPOSER=$$(command -v composer); \
		if test $$? -eq 0; \
		then \
			ln -s $$COMPOSER composer.phar; \
		else \
			curl $(BTR_SILENT_FLAG) -S http://getcomposer.org/installer | php; \
		fi; \
	) >>$(BTR_CONFIG_REPORT)

$(BTR_BUILD_DIR)/composer.json: $(BTR_BRANCH_DIR)/composer.json | $(BTR_BUILD_DIR) $(BTR_LOG_DIR)
	rsync $(BTR_QUIET_FLAG) $(BTR_VERBOSE_FLAG) -a --delete $(BTR_BRANCH_DIR)/ $(BTR_BUILD_DIR)/ \
		>>$(BTR_CONFIG_REPORT)

$(BTR_BUILD_DIR)/composer.lock: $(BTR_BUILD_DIR)/composer.json $(BTR_BUILD_DIR)/composer.phar

# vim: noet
