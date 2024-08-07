ALLOYSV=10d758b46c28d97b27fcc545770bd39f8ba41ecc
RUSTC=alloy/bin/bin/rustc

EXAMPLES=first_example.out rc_example.out dangling_reference.stderr \
	 finaliser_deadlock.stderr


all: ${EXAMPLES}

clean:
	rm -rf ${EXAMPLES}

%.out: %.rs ${RUSTC} alloy
	${RUSTC} $< -o $@

%.stderr: %.rs ${RUSTC} alloy
	${RUSTC} $< 2> $@ || true
	grep -q -i 'cannot be safely constructed\|finalized' $@

${RUSTC}: alloy
	cd alloy && ./configure --set install.prefix=bin --set install.sysconfdir=etc --set build.extended=false \
		&& ./x.py install

alloy:
	git clone https://github.com/softdevteam/alloy
	cd alloy && git checkout ${ALLOYSV}