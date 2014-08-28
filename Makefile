.PHONY: eki

all: eki
	@echo "Creating eki script."
	@./concat

clean:
	rm -f eki
