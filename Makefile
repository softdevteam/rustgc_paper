.SUFFIXES: .ltx .ps .pdf .svg

.svg.pdf:
	inkscape --export-pdf=$@ $<

LATEX_FILES = rustgc_paper.ltx


PLOTS = plots/som_rs_bc_elision.pdf plots/som_rs_ast_elision.pdf \
	 plots/som_rs_bc_barriers.pdf plots/som_rs_ast_barriers.pdf \
	 plots/yksom_elision.pdf plots/yksom_barriers.pdf \
	 plots/elision.pdf plots/elision_mem.pdf \
	 plots/barriers.pdf plots/barriers_mem.pdf \
	 plots/grmtools.pdf plots/grmtools_mem.pdf

all: rustgc_paper.pdf

clean:
	rm -f ${DIAGRAMS}
	rm -f rustgc_paper.aux rustgc_paper.bbl rustgc_paper.blg rustgc_paper.dvi rustgc_paper.log rustgc_paper.pdf rustgc_paper.toc rustgc_paper.out rustgc_paper.snm rustgc_paper.nav rustgc_paper.vrb texput.log
	rm -f rustgc_paper_preamble.fmt rustgc_paper_preamble.log

rustgc_paper.pdf: bib.bib ${LATEX_FILES} ${DIAGRAMS} ${PLOTS} rustgc_paper_preamble.fmt
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

bib.bib: softdevbib/softdev.bib local.bib
	softdevbib/bin/prebib softdevbib/softdev.bib > bib.bib
	softdevbib/bin/prebib local.bib >> bib.bib

softdevbib/softdev.bib:
	git submodule init
	git submodule update
