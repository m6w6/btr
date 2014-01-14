.PHONY: all
.SUFFIXES:

all:
	curl "https://api.twilio.com/2010-04-01/Accounts/$(TWILIO_ACCOUNT)/SMS/Messages.json" \
	--data-urlencode "From=$(TWILIO_NUMBER)" \
	--data-urlencode "To=$(BTR_REPORT_NUMBER)" \
	--data-urlencode "Body=[btr] $(BTR_BUILD) $$(cat $(BTR_REPORT))" \
	-u $(TWILIO_ACCOUNT):$(TWILIO_TOKEN)

# vim: noet
