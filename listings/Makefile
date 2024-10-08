ALLOYSV=0772ea06e71bd5643688a90a5b61fd980e8cfc92
EXAMPLES=first_example.out rc_example.out dangling_reference.stderr \
	 finaliser_deadlock.stderr


all: $(EXAMPLES)

clean:
	rm -rf $(EXAMPLES)

%.out: %.rs alloy
	$(RUSTC) $< -o $@

%.stderr: %.rs alloy
	$(RUSTC) $< 2> $@ || true
	@# This is a hack to ensure that any non FSA-related compiler error
	@# causes the build to fail. This works because rust errors are usually
	@# written in the form error[ERRNO] but FSA does not provide ERRNO
	@# values.
	! grep -q 'error\[' $@
	grep -q -i 'cannot be safely constructed\|finalized' $@

ifdef RUSTC
alloy:
	@echo "Using $(RUSTC)"
else
alloy: alloy
	cd alloy && ./configure --set install.prefix=bin \
		--set install.sysconfdir=etc --set build.extended=false \
		&& ./x.py install

ALLOY_SRC_DIR = $(PWD)/alloy

$(ALLOY_SRC_DIR):
	git clone https://github.com/softdevteam/alloy $(ALLOY_SRC_DIR)
	cd $(ALLOY_SRC_DIR) && git checkout $(ALLOYSV)
endif
