let () =
  print_endline "#include <portmidi.h>";
  Cstubs_structs.write_c Format.std_formatter (module Portmidi_c_type_descriptions.Types)
