(lang dune 2.0)
(name portmidi)

(generate_opam_files true)
(license "LGPL-2.1-or-later with OCaml-LGPL-linking-exception")
(authors "Michael Bacarella <m@bacarella.com>")
(maintainers "Michael Bacarella <m@bacarella.com>")
(homepage "https://github.com/mbacarella/portmidi")
(bug_reports "https://github.com/mbacarella/portmidi/issues")
(package
  (name portmidi)
  (synopsis "MP3 decoding library")
  (description "OCaml bindings to libportmidi")
  (depends
    (ocaml (>= 4.03))
    (dune (>= 2.0))
    dune-configurator
    conf-pkg-config
    ctypes
    ctypes-foreign
    conf-libportmidi
  ))
