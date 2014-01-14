BTR_REPORT_ARGS=$(USER)

.PHONY: all
.SUFFIXES:

all: 
	$(SAY) "Mailing report to $(BTR_REPORT_ARGS)"
	@printf "\nbtr %s %s\n\n-- \nbtr mail report\n" "$(BTR_BUILD)" "$$(cat $(BTR_REPORT))" | \
		mail -s "[btr] $(BTR_BUILD) $$(cat $(BTR_REPORT))" \
			-a $(BTR_CONFIG_REPORT) \
			-a $(BTR_BUILD_REPORT) \
			-a $(BTR_TEST_REPORT) \
			$(BTR_REPORT_ARGS)

# vim: noet
