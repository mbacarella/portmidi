This is an OCaml package that provides bindings to the portmidi library.

It uses the excellent ctypes library to generate the C-stubs which should help
minimize the bugspace.

Installing
===

One day, you will be able to do
```
opam install portmidi
```

but see below.

Status
---

Not released to opam yet.  Still pretty devvy.  Open/read/write works.  Reading sysex messages is untested so far.

Try

```
opam pin add portmidi git+https://github.com/mbacarella/portmidi
```
