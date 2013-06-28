.PHONY: all
.SUFFIXES:

all: 
	MESSAGE=$$(printf "\nbtr %s %s\n\n-- \nbtr mail report\n" "$(BUILD)" "$(REPORT)"); \
	mail -s "[btr] $(BUILD) $(REPORT)" \
		-a $(CONFIG_REPORT) -a $(BUILD_REPORT) -a $(TEST_REPORT) \
		$(USER) <<<"$$MESSAGE"

# vim: set noet
