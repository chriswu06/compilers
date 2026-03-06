UNAME := $(shell uname)

ifeq ($(shell uname), Darwin)
	LANGS_CC ?= arch -x86_64 clang
	LANGS_AS ?= arch -x86_64 clang -c
else
	LANGS_CC ?= clang
	LANGS_AS ?= clang -c
endif

objs = \
	main.o \
	print.o \
	values.o

.DEFAULT_GOAL: submit.zip

submit.zip: $(shell find . -name "*.rkt" -o -name "*.c")
	zip submit.zip -r * \
		-x \*.[os] -x \*~ -x \*zip \
		-x \*Zone.Identifier -x \*\*compiled\*\*

runtime.o: $(objs)
	ld -r $(objs) -o runtime.o

%.run: %.o runtime.o
	$(CC) runtime.o $< -o $@

.c.o:
	$(CC) -fPIC -c -g -o $@ $<

.s.o:
	nasm -g -f $(format) -o $@ $<

%.s: %.rkt
	cat $< | racket -t compile-stdin.rkt -m > $@

clean:
	@$(RM) *.o *.s *.run ||:
	@echo "$(shell basename $(shell pwd)): cleaned!"

%.test: %.run %.rkt
	@test "$(shell ./$(<))" = "$(shell racket $(word 2,$^))"
