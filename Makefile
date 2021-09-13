default: release

check:
	dune build @runtest
	dune build @check

release:
	dune build --profile=release

fmt:
	dune build @fmt --auto-promote

clean:
	dune clean
