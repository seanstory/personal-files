CHROME := $(shell command -v chromium 2>/dev/null || command -v google-chrome 2>/dev/null)

.PHONY: resume clean

resume:
ifndef CHROME
	$(error No Chrome or Chromium found. Install via: brew install --cask google-chrome)
endif
	$(CHROME) --headless --print-to-pdf=resume.pdf --no-pdf-header-footer \
		--run-all-compositor-stages-before-draw \
		"$(shell pwd)/resume/resume.html"

clean:
	rm -f resume.pdf
