.PHONY: all
.SUFFIXES:

all: 
	$(SAY) "Notifying $(USER) about the report"
	CONFIG_URL=$$(curl -sSF sprunge="@$(CONFIG_REPORT)" sprunge.us); \
	BUILD_URL=$$(curl -sSF sprunge="@$(BUILD_REPORT)" sprunge.us); \
	TEST_URL=$$(curl -sSF sprunge="@$(TEST_REPORT)" sprunge.us); \
	notify-send $(REPORT_ARGS) "[btr] $(BUILD) $$(cat $(REPORT))" \
		"Config: $$CONFIG_URL -- Build: $$BUILD_URL -- Test:$$TEST_URL";

# vim: noet
