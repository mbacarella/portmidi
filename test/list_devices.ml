open! Core_kernel

let () =
  match Portmidi.initialize () with
  | Ok () -> ()
  | Error _e -> failwith "error initializing portmidi"

let () =
  let num_devices = Portmidi.count_devices () in
  printf "number of devices: %d\n" num_devices;
  for i=0 to (pred num_devices); do
    printf "device %d\n" i;
    match Portmidi.get_device_info i with
    | None -> printf "device %d not found\n" i
    | Some di ->
      printf "      name: %s\n" (Option.value ~default:"null" di.Portmidi.Device_info.name);
      printf " interface: %s\n" (Option.value ~default:"null" di.Portmidi.Device_info.interface)
      (*
      printf "     input: %b\n" di.Portmidi.Device_info.input;
      printf "    output: %b\n" di.Portmidi.Device_info.output;
         *)
  done

let () =
  Portmidi.terminate ()
