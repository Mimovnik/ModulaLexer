#
CC=gcc
LEX=flex

% : %.tab.o %.o 
	$(CC) $< $*.o $(LDFLAGS) -o $@

%.tab.c %.tab.h: %.y
	bison -d $<

%.c: %.l %.tab.h
	$(LEX) -t $< > $@

lexer: lexer.y lexer.l
parser: parser.y parser.l

