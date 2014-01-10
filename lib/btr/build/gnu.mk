BUILD_CLEAN=false
BUILD_ARGS=
TEST_ARGS=

.PHONY: all clean
.SUFFIXES:

CONFIGS=$(wildcard $(BRANCH_DIR)/configure.*)

all: clean $(REPORT)
	$(SAY) "Result: $$(cat $(REPORT))"

clean: $(CONFIG_REPORT)
	if $(BUILD_CLEAN); \
	then \
		cd $(BUILD_DIR) && \
			make $(SILENT_FLAG) clean; \
	fi;

$(REPORT): $(TEST_REPORT)
	if test -z "$(LAST_REPORT)"; then \
		echo 0; \
	elif test -s "$(LAST_REPORT)" -o -s "$(TEST_REPORT)"; then \
		cmp $(LAST_REPORT) $(TEST_REPORT) 2>&1 || true; \
	else \
		echo 0; \
	fi;

$(TEST_REPORT): $(BUILD_REPORT)
	$(SAY) "Running checks..."
	cd $(BUILD_DIR) && \
		make check $(TEST_ARGS) >../$@ 2>&1

$(BUILD_REPORT): $(CONFIG_REPORT)
	$(SAY) "Making build..."
	cd $(BUILD_DIR) && \
		make -j $(CPUS) >../$@ 2>&1
	
$(CONFIG_REPORT): $(BRANCH_DIR)/configure $(BUILD_DIR)
	$(SAY) "Running configure..."
	cd $(BUILD_DIR) && \
		../$(BRANCH_DIR)/configure -C $(BUILD_ARGS) >../$@ 2>&1

$(BUILD_DIR):
	mkdir -p $@
	
$(BRANCH_DIR)/configure: $(CONFIGS)
	$(SAY) "Building configure..."
	cd $(BRANCH_DIR) && \
		autoreconf -i -f -W none >/dev/null

# vim: noet
