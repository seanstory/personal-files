CHROME := $(shell command -v chromium 2>/dev/null || command -v google-chrome 2>/dev/null)

.PHONY: resume clean

resume:
	@CHROME="$$(command -v chromium 2>/dev/null || command -v google-chrome 2>/dev/null)"; \
	if [ -z "$$CHROME" ]; then \
		echo "chromium not found on PATH — installing via brew..."; \
		brew install chromium; \
		CHROME="$$(command -v chromium)"; \
	fi; \
	"$$CHROME" --headless --print-to-pdf=resume.pdf --no-pdf-header-footer \
		--run-all-compositor-stages-before-draw \
		"$(shell pwd)/resume/resume.html"

clean:
	rm -f resume.pdf
