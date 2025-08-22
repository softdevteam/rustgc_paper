.SUFFIXES: .ltx .ps .pdf .svg

.svg.pdf:
	inkscape --export-filename=$@ $<

LATEX_FILES = rustgc_paper.ltx macros.tex experiment_stats.tex
PLOTS = $(patsubst %.svg,%.pdf, $(shell find . -type f -name "*.svg"))
FIGURES = $(shell find figures/ -type f -name "*.pgf")
PGFCACHE = _pgfcache
TABLES = $(shell find tables/ -type f -name "*.tex")

ARXIV_FILES = softdev.sty \
		listings-rust.sty \
		bib.bib \
		rustgc_paper.bbl \
		experiment_stats.tex \
		ripgrep_subset.pdf \
		listings/dangling_reference.rs \
		listings/finalization_cycle.rs \
		listings/finalizer_deadlock.rs \
		listings/finalization_cycle.stderr \
		listings/first_example.rs \
		listings/rc_example.rs \
		listings/thread_unsafety.rs

ARXIV_BASE=arxiv

all: appendices.pdf main.pdf rustgc_paper.pdf

rustgc_paper.pdf: bib.bib ${PLOTS} $(PGFCACHE) $(FIGURES) $(TABLES) rustgc_paper_preamble.fmt $(LATEX_FILES)
	pdflatex  -shell-escape rustgc_paper.ltx
	bibtex rustgc_paper
	pdflatex  -shell-escape rustgc_paper.ltx
	pdflatex  -shell-escape rustgc_paper.ltx

appendices.pdf main.pdf: rustgc_paper.pdf
	pdfjam -o main.pdf rustgc_paper.pdf 1-26
	pdfjam -o appendices.pdf rustgc_paper.pdf 27-

rustgc_paper_preamble.fmt: rustgc_paper_preamble.ltx experiment_stats.tex
	set -e; \
	  tmpltx=`mktemp`; \
	  cat ${@:fmt=ltx} > $${tmpltx}; \
	  grep -v "%&${@:_preamble.fmt=}" ${@:_preamble.fmt=.ltx} >> $${tmpltx}; \
	  pdftex -ini -jobname="${@:.fmt=}" "&pdflatex" mylatexformat.ltx $${tmpltx}; \
	  rm $${tmpltx}

diff.pdf: rustgc_paper.pdf
	git show oopsla_submission:rustgc_paper.ltx > submitted.ltx
	sed '/begin.acks/,/end.acks/d' rustgc_paper.ltx > rustgc_paper_for_diff.ltx
	latexdiff submitted.ltx rustgc_paper_for_diff.ltx > diff.ltx
	pdflatex diff.ltx
	bibtex diff
	pdflatex diff.ltx
	pdflatex diff.ltx

$(PGFCACHE):
	mkdir -p $@

bib.bib: softdevbib/softdev.bib local.bib
	softdevbib/bin/prebib softdevbib/softdev.bib > bib.bib
	softdevbib/bin/prebib local.bib >> bib.bib

response.pdf: response.tex
	pdflatex response.tex

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
	rm -rf _pgfcache
