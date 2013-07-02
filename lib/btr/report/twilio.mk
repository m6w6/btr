.PHONY: all
.SUFFIXES:

all:
	curl "https://api.twilio.com/2010-04-01/Accounts/$(TWILIO_ACCOUNT)/SMS/Messages.json" \
	--data-urlencode "From=$(TWILIO_NUMBER)" \
	--data-urlencode "To=$(REPORT_NUMBER)" \
	--data-urlencode "Body=[btr] $(BUILD) $(REPORT)" \
	-u $(TWILIO_ACCOUNT):$(TWILIO_TOKEN)

# vim: noet
