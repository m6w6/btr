.PHONY: all
.SUFFIXES:

CONFIGS=$(wildcard $(BRANCH_DIR)/configure.*)

all: $(TEST_REPORT)
	if test -z "$(LAST_REPORT)"; then \
		echo 0; \
	elif test -s "$(LAST_REPORT)" -o -s "$(TEST_REPORT)"; then \
		cmp $(LAST_REPORT) $(TEST_REPORT); 2>&1 || true \
	else \
		echo 0; \
	fi;

$(TEST_REPORT): $(BUILD_REPORT)
	cd $(BUILD_DIR) && \
	make check $(CHECKS) > ../$@

$(BUILD_REPORT): $(CONFIG_REPORT)
	cd $(BUILD_DIR) && \
	make -j $(CPUS) > ../$@
	
$(CONFIG_REPORT): $(BRANCH_DIR)/configure $(BUILD_DIR)
	cd $(BUILD_DIR) && \
	../$(BRANCH_DIR)/configure -C $(CONFIGURE) > ../$@

$(BUILD_DIR):
	mkdir -p $@
	
$(BRANCH_DIR)/configure: $(CONFIGS)
	cd $(BRANCH_DIR) && \
	autoreconf -i -f -W none >/dev/null

# vim: noet
