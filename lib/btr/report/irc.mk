.PHONY: all
.SUFFIXES:

all: 
	$(SAY) "Notifying IRC ($(REPORT_ARGS))"
	CONFIG_URL=$$(curl -sSF sprunge="@$(CONFIG_REPORT)" sprunge.us); \
	BUILD_URL=$$(curl -sSF sprunge="@$(BUILD_REPORT)" sprunge.us); \
	TEST_URL=$$(curl -sSF sprunge="@$(TEST_REPORT)" sprunge.us); \
	$(BINDIR)/btr-irc-send "$(REPORT_ARGS)" "[btr] $(BUILD) $$(cat $(REPORT)) \
		-- Config: $$CONFIG_URL -- Build: $$BUILD_URL -- Test: $$TEST_URL";

# vim: noet
