CHROME := $(shell command -v chromium 2>/dev/null \
    || command -v google-chrome 2>/dev/null \
    || (test -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
        && echo "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"))

# Override HTML to print a tailored variant, e.g.
#   make resume HTML=resume/out/acme.html   # -> resume/out/acme.pdf
HTML ?= resume/resume.html
PDF ?= $(if $(filter resume/resume.html,$(HTML)),resume.pdf,$(HTML:.html=.pdf))

.PHONY: resume clean

resume:
ifndef CHROME
	$(error No Chrome or Chromium found. Install Chrome from https://www.google.com/chrome/ or put chromium on PATH)
endif
	"$(CHROME)" --headless --print-to-pdf="$(PDF)" --no-pdf-header-footer \
		--run-all-compositor-stages-before-draw \
		"$(abspath $(HTML))"

clean:
	rm -f resume.pdf
