.PHONY: resume clean

resume:
	@if ! CHROME=$$(command -v chromium 2>/dev/null || command -v google-chrome 2>/dev/null); then \
		if [ -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]; then \
			CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"; \
		else \
			echo "No Chrome or Chromium found. Install via: brew install --cask google-chrome"; \
			exit 1; \
		fi; \
	fi; \
	"$$CHROME" --headless --print-to-pdf=resume.pdf --no-pdf-header-footer \
		--run-all-compositor-stages-before-draw \
		"$$(pwd)/resume/resume.html"

clean:
	rm -f resume.pdf
