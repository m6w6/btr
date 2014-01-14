.PHONY: all
.SUFFIXES:

all: 
	$(SAY) "Notifying IRC ($(BTR_REPORT_ARGS))"
	BTR_CONFIG_URL=$$(curl -sSF sprunge="@$(BTR_CONFIG_REPORT)" sprunge.us); \
	BTR_BUILD_URL=$$(curl -sSF sprunge="@$(BTR_BUILD_REPORT)" sprunge.us); \
	BTR_TEST_URL=$$(curl -sSF sprunge="@$(BTR_TEST_REPORT)" sprunge.us); \
	$(BTR_BINDIR)/btr-irc-send "$(BTR_REPORT_ARGS)" "[btr] $(BTR_BUILD) $$(cat $(BTR_REPORT)) \
		-- Config: $$BTR_CONFIG_URL -- Build: $$BTR_BUILD_URL -- Test: $$BTR_TEST_URL";

# vim: noet
