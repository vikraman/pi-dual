########################################################################
# Phony targets are scoped, so you probably want to declare them first.
#

.PHONY : clean clean-subcode

outline.subc.pdf : outline.subc.tex cites.bib
	pdflatex -halt-on-error outline.subc.tex

outline.subc.tex : outline.tex
	ruby subcode/subc.rb outline.tex

r.subc.pdf : r.subc.tex cites.bib
	pdflatex -halt-on-error r.subc.tex
	bibtex r.subc
	pdflatex -halt-on-error r.subc.tex
	pdflatex -halt-on-error r.subc.tex

r.subc.tex : r.tex
	ruby subcode/subc.rb r.tex

agda-sabry: Pi.agda PiN.agda PiF.agda PiNF-syntax.agda PiNF-algebra.agda PiNF-semantics.agda Pi-abstract-machine.agda Pi-reasoning.agda oldPi.agda
	touch /u/sabry/.hyplan/pi
	/bin/rm -r /u/sabry/.hyplan/pi
	agda --html-dir=/u/sabry/.hyplan/pi --allow-unsolved-metas --html -i . -i /u/sabry/include/agda2/src Pi.agda
	agda --html-dir=/u/sabry/.hyplan/pi --allow-unsolved-metas --html -i . -i /u/sabry/include/agda2/src PiN.agda
	agda --html-dir=/u/sabry/.hyplan/pi --allow-unsolved-metas --html -i . -i /u/sabry/include/agda2/src PiF.agda
	agda --html-dir=/u/sabry/.hyplan/pi --allow-unsolved-metas --html -i . -i /u/sabry/include/agda2/src PiNF-syntax.agda
	agda --html-dir=/u/sabry/.hyplan/pi --allow-unsolved-metas --html -i . -i /u/sabry/include/agda2/src PiNF-algebra.agda
	agda --html-dir=/u/sabry/.hyplan/pi --allow-unsolved-metas --html -i . -i /u/sabry/include/agda2/src PiNF-semantics.agda
	agda --html-dir=/u/sabry/.hyplan/pi --allow-unsolved-metas --html -i . -i /u/sabry/include/agda2/src Pi-abstract-machine.agda
	agda --html-dir=/u/sabry/.hyplan/pi --allow-unsolved-metas --html -i . -i /u/sabry/include/agda2/src Pi-reasoning.agda
	agda --html-dir=/u/sabry/.hyplan/pi --allow-unsolved-metas --html -i . -i /u/sabry/include/agda2/src oldPi.agda

# Clean
clean: 
	rm *.subc.*
	rm .subcode_cache*

clean-subcode:
	rm .subcode_cache*

