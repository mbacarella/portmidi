open! Core_kernel

let () =
  match Portmidi.initialize () with
  | Ok () -> ()
  | Error _e -> failwith "error initializing portmidi"

let () =
  let device_id = Int.of_string Sys.argv.(1) in
  match Portmidi.open_output ~device_id ~buffer_size:0l ~latency:0l with
  | Ok _stream -> printf "device %d successfully opened for output!\n" device_id
  (*
    let _ = Portmidi.close_output stream in
    ()
       *)
  | Error err ->
    printf
      "device %d failed to open for output: %s\n"
      device_id
      (Option.value ~default:"null" @@ Portmidi.get_error_text err)

let () = Portmidi.terminate ()
