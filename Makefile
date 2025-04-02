.SUFFIXES: .ltx .ps .pdf .svg

.svg.pdf:
	inkscape --export-filename=$@ $<

LATEX_FILES = rustgc_paper.ltx

PLOTS = $(patsubst %.svg,%.pdf, $(shell find . -type f -name "*.svg"))

ARXIV_FILES = softdev.sty \
		listings-rust.sty \
		bib.bib \
		rustgc_paper.bbl \
		experiment_stats.tex \
		ripgrep_subset.pdf \
		plots/gcvs/perf_summary.tex \
		plots/gcvs/mem_summary.tex \
		plots/elision/perf_summary.tex \
		plots/elision/mem_summary.tex \
		plots/premopt/perf_summary.tex \
		plots/premopt/mem_summary.tex \
		plots/gcvs/alacritty/perf/alacritty.pdf \
		plots/gcvs/alacritty/profiles/alacritty.pdf \
		plots/gcvs/fd/perf/fd.pdf \
		plots/gcvs/fd/profiles/fd.pdf \
		plots/gcvs/grmtools/perf/grmtools.pdf \
		plots/gcvs/grmtools/profiles/grmtools.pdf \
		plots/gcvs/ripgrep/perf/ripgrep.pdf \
		plots/gcvs/ripgrep/profiles/ripgrep.pdf \
		plots/gcvs/som/perf/som-rs-ast.pdf \
		plots/gcvs/som/perf/som-rs-bc.pdf \
		plots/gcvs/som/profiles/som-rs-ast.pdf \
		plots/gcvs/som/profiles/som-rs-bc.pdf \
		listings/dangling_reference.rs \
		listings/finalization_cycle.rs \
		listings/finalizer_deadlock.rs \
		listings/finalization_cycle.stderr \
		listings/first_example.rs \
		listings/rc_example.rs \
		listings/thread_unsafety.rs

ARXIV_BASE=arxiv

all: appendices.pdf main.pdf rustgc_paper.pdf

rustgc_paper.pdf: bib.bib ${LATEX_FILES} ${PLOTS} rustgc_paper_preamble.fmt experiment_stats.tex plots/gcvs/perf_summary.tex
	pdflatex rustgc_paper.ltx
	bibtex rustgc_paper
	pdflatex rustgc_paper.ltx
	pdflatex rustgc_paper.ltx

appendices.pdf main.pdf: rustgc_paper.pdf
	pdfjam -o main.pdf rustgc_paper.pdf 1-24
	pdfjam -o appendices.pdf rustgc_paper.pdf 25-

rustgc_paper_preamble.fmt: rustgc_paper_preamble.ltx experiment_stats.tex
	set -e; \
	  tmpltx=`mktemp`; \
	  cat ${@:fmt=ltx} > $${tmpltx}; \
	  grep -v "%&${@:_preamble.fmt=}" ${@:_preamble.fmt=.ltx} >> $${tmpltx}; \
	  pdftex -ini -jobname="${@:.fmt=}" "&pdflatex" mylatexformat.ltx $${tmpltx}; \
	  rm $${tmpltx}

bib.bib: softdevbib/softdev.bib local.bib
	softdevbib/bin/prebib softdevbib/softdev.bib > bib.bib
	softdevbib/bin/prebib local.bib >> bib.bib

softdevbib/softdev.bib:
	git submodule init
	git submodule update

${ARXIV_BASE}: rustgc_paper.pdf
	mkdir $@
	rsync -Rav ${ARXIV_FILES} $@
	echo "\input{rustgc_paper_preamble.ltx}" > $@/rustgc_paper.tex
	cat rustgc_paper.ltx | grep -v "%&rustgc_paper_preamble" | grep -v "\\endofdump" >> $@/rustgc_paper.tex
	sed -i'.bk' '/\\endofdump/d' $@/rustgc_paper.tex
	rm -f $@/rustgc_paper.tex.bk
	tmpltx=`mktemp`; \
	latexpand $@/rustgc_paper.tex > $${tmpltx} && cp $${tmpltx} $@/rustgc_paper.tex;
	zip -r $@.zip ${ARXIV_BASE}

clean-arxiv:
	rm -rf arxiv
	rm -rf arxiv.zip

clean: clean-arxiv
	rm -f ${PLOTS}
	rm -f rustgc_paper.aux rustgc_paper.bbl rustgc_paper.blg rustgc_paper.dvi rustgc_paper.log rustgc_paper.pdf rustgc_paper.toc rustgc_paper.out rustgc_paper.snm rustgc_paper.nav rustgc_paper.vrb texput.log
	rm -f rustgc_paper_preamble.fmt rustgc_paper_preamble.log
