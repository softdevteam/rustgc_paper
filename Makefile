.SUFFIXES: .ltx .ps .pdf .svg

.svg.pdf:
	inkscape --export-pdf=$@ $<

LATEX_FILES = rustgc_paper.ltx


DIAGRAMS = images/finaliser_cycle1.pdf images/finaliser_cycle2.pdf \
		   images/ordered_finalisation.pdf images/alloy_finaliser_memory.pdf \
		   images/alloy_inner_gc.pdf images/early_finalisation.pdf \
		   images/finaliser_elision_1.pdf images/finaliser_elision_2.pdf \
		   images/finaliser_elision_3.pdf images/finaliser_elision_4.pdf \
		   images/finaliser_elision_5.pdf images/finaliser_elision_6.pdf \
		   images/finaliser_elision_7.pdf images/finaliser_elision_8.pdf \
		   images/partial_finaliser_elision_1.pdf

all: rustgc_paper.pdf

clean:
	rm -f ${DIAGRAMS}
	rm -f rustgc_paper.aux rustgc_paper.bbl rustgc_paper.blg rustgc_paper.dvi rustgc_paper.log rustgc_paper.pdf rustgc_paper.toc rustgc_paper.out rustgc_paper.snm rustgc_paper.nav rustgc_paper.vrb texput.log
	rm -f rustgc_paper_preamble.fmt rustgc_paper_preamble.log

rustgc_paper.pdf: bib.bib ${LATEX_FILES} ${DIAGRAMS} rustgc_paper_preamble.fmt
	pdflatex rustgc_paper.ltx
	bibtex rustgc_paper
	pdflatex rustgc_paper.ltx
	pdflatex rustgc_paper.ltx

rustgc_paper_preamble.fmt: rustgc_paper_preamble.ltx
	set -e; \
	  tmpltx=`mktemp`; \
	  cat ${@:fmt=ltx} > $${tmpltx}; \
	  grep -v "%&${@:_preamble.fmt=}" ${@:_preamble.fmt=.ltx} >> $${tmpltx}; \
	  pdftex -ini -jobname="${@:.fmt=}" "&pdflatex" mylatexformat.ltx $${tmpltx}; \
	  rm $${tmpltx}

bib.bib: softdevbib/softdev.bib
	softdevbib/bin/prebib softdevbib/softdev.bib > bib.bib

softdevbib/softdev.bib:
	git submodule init
	git submodule update
