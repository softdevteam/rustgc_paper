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
		   images/alloy_basic_gc_1.pdf images/alloy_basic_gc_2.pdf \
		   images/alloy_basic_gc_3.pdf images/gc_roots.pdf \
		   images/partial_finaliser_elision_1.pdf images/invalid_reference_finaliser.pdf \
		   images/finaliser_cycle_unsound.pdf

GRAPHS = graphs/bounce_memory.pdf graphs/bubblesort_memory.pdf \
		 graphs/deltablue_memory.pdf graphs/dispatch_memory.pdf \
		 graphs/fannkuch_memory.pdf graphs/fibonacci_memory.pdf \
		 graphs/fieldloop_memory.pdf graphs/graphsearch_memory.pdf \
		 graphs/integerloop_memory.pdf graphs/jsonsmall_memory.pdf \
		 graphs/list_memory.pdf graphs/loop_memory.pdf \
		 graphs/mandelbrot_memory.pdf graphs/nbody_memory.pdf \
		 graphs/nbody_memory.pdf graphs/pagerank_memory.pdf \
		 graphs/permute_memory.pdf graphs/queens_memory.pdf \
		 graphs/quicksort_memory.pdf graphs/recurse_memory.pdf \
		 graphs/richards_memory.pdf graphs/sieve_memory.pdf \
		 graphs/storage_memory.pdf graphs/sum_memory.pdf \
		 graphs/towers_memory.pdf graphs/treesort_memory.pdf \
		 graphs/whileloop_memory.pdf graphs/som_bar.pdf \
		 graphs/box_vs_rs_memory.pdf graphs/call_performance_memory.pdf \
		 graphs/jmptbl_memory.pdf graphs/nvec_memory.pdf \
		 graphs/wlambda_bar.pdf graphs/som_bar_new.pdf \
		 graphs/som_rs_finalisers.pdf graphs/yksom_finalisers.pdf \
		 graphs/som_rs_perf.pdf graphs/som_rs_barriers.pdf \
		 graphs/yksom_barriers.pdf graphs/binary_trees.pdf \
		 graphs/regex_redux.pdf

all: rustgc_paper.pdf

clean:
	rm -f ${DIAGRAMS}
	rm -f rustgc_paper.aux rustgc_paper.bbl rustgc_paper.blg rustgc_paper.dvi rustgc_paper.log rustgc_paper.pdf rustgc_paper.toc rustgc_paper.out rustgc_paper.snm rustgc_paper.nav rustgc_paper.vrb texput.log
	rm -f rustgc_paper_preamble.fmt rustgc_paper_preamble.log

rustgc_paper.pdf: bib.bib ${LATEX_FILES} ${DIAGRAMS} ${GRAPHS} rustgc_paper_preamble.fmt
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
