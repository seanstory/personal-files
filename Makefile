CHROME := $(shell command -v chromium 2>/dev/null \
    || command -v google-chrome 2>/dev/null \
    || (test -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
        && echo "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"))

.PHONY: resume clean

resume:
ifndef CHROME
	$(error No Chrome or Chromium found. Install Chrome from https://www.google.com/chrome/ or put chromium on PATH)
endif
	"$(CHROME)" --headless --print-to-pdf=resume.pdf --no-pdf-header-footer \
		--run-all-compositor-stages-before-draw \
		"$(shell pwd)/resume/resume.html"

clean:
	rm -f resume.pdf
