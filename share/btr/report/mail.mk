REPORT_ARGS=$(USER)

.PHONY: all
.SUFFIXES:

all: 
	$(SAY) "Mailing report to $(REPORT_ARGS)"
	@printf "\nbtr %s %s\n\n-- \nbtr mail report\n" "$(BUILD)" "$$(cat $(REPORT))" | \
		mail -s "[btr] $(BUILD) $$(cat $(REPORT))" \
			-a $(CONFIG_REPORT) \
			-a $(BUILD_REPORT) \
			-a $(TEST_REPORT) \
			$(REPORT_ARGS)

# vim: noet
