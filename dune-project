(lang dune 2.7)

(name portmidi)

(generate_opam_files true)

(license "LGPL-2.1-or-later with OCaml-LGPL-linking-exception")

(authors "Michael Bacarella <m@bacarella.com>")

(maintainers "Michael Bacarella <m@bacarella.com>")

(homepage "https://github.com/mbacarella/portmidi")

(source
 (github mbacarella/portmidi))

(package
 (name portmidi)
 (synopsis "Bindings to libportmidi")
 (description "OCaml bindings to libportmidi")
 (depends
  (ocaml
   (>= 4.03))
  dune-configurator
  conf-pkg-config
  core_kernel
  (ctypes
   (>= 0.13.0))
  ctypes-foreign
  conf-libportmidi
  ppx_jane))
