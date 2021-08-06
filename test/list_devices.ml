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
  let num_devices = Portmidi.count_devices () in
  printf "number of devices: %d\n" num_devices;
  for i = 0 to pred num_devices do
    printf "device %d\n" i;
    match Portmidi.get_device_info i with
    | None -> printf "device %d not found\n" i
    | Some di ->
      printf "      name: %s\n" (Option.value ~default:"null" di.Portmidi.Device_info.name);
      printf " interface: %s\n" (Option.value ~default:"null" di.Portmidi.Device_info.interface);
      printf "     input: %B\n" di.Portmidi.Device_info.input;
      printf "    output: %B\n" di.Portmidi.Device_info.output
  done

let () = Portmidi.terminate ()
