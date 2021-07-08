open! Core_kernel

(*
number of devices: 4
device 0
      name: Midi Through Port-0
 interface: ALSA
     input: false
    output: true
device 1
      name: Midi Through Port-0
 interface: ALSA
     input: true
    output: false
device 2
      name: DDJ-400 MIDI 1
 interface: ALSA
     input: false
    output: true
device 3
      name: DDJ-400 MIDI 1
 interface: ALSA
     input: true
    output: false
*)

let () =
  match Portmidi.initialize () with
  | Ok () -> ()
  | Error _e -> failwith "error initializing portmidi"

let () =
  let device_id = Int.of_string Sys.argv.(1) in
  match Portmidi.open_input ~device_id ~buffer_size:1024l with
  | Ok stream ->
    printf "device %d successfully opened for input!\n" device_id;
    let _ = Portmidi.close_input stream in
    ()
  | Error err ->
    printf "device %d failed to open for input: %s\n"
      device_id
      (Option.value ~default:"null" @@ Portmidi.get_error_text err)

let () =
  Portmidi.terminate ()
