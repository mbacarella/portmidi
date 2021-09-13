open! Core_kernel
open! No_polymorphic_compare [@@warning "-66"]

module Device_info = struct
  type t =
    { interface : string option;
      name : string option;
      input : bool;
      output : bool;
      struct_version_internal : int;
      opened_internal : bool
    }
  [@@deriving sexp, fields]
end

module Portmidi_error = struct
  type t =
    [ `Got_data
    | `Host_error
    | `Invalid_device_id
    | `Insufficient_memory
    | `Buffer_too_small
    | `Bad_ptr
    | `Bad_data
    | `Internal_error
    | `Buffer_max_size
    ]
  [@@deriving sexp, variants]
end

let message_status msg = Int32.bit_and msg 0xFFl
let message_data1 msg = Int32.bit_and (Int32.( lsr ) msg 8) 0xFFl
let message_data2 msg = Int32.bit_and (Int32.( lsr ) msg 16) 0xFFl

module Portmidi_event = struct
  type t =
    { message : Int32.t;
      timestamp : Int32.t
    }
  [@@deriving sexp, fields]

  let create ~status ~data1 ~data2 ~timestamp =
    let message =
      let status = Char.to_int status |> Int32.of_int_exn in
      let data1 = Char.to_int data1 |> Int32.of_int_exn in
      let data2 = Char.to_int data2 |> Int32.of_int_exn in
      let status_masked = Int32.bit_and status 0xFFl in
      let data1_masked = Int32.bit_and (Int32.( lsl ) data1 8) 0xFFl in
      let data2_masked = Int32.bit_and (Int32.( lsl ) data2 16) 0xFFl in
      Int32.bit_or status_masked data1_masked |> Int32.bit_or data2_masked
    in
    { message; timestamp }
end

module Input_stream = struct
  type t = unit Ctypes_static.ptr
end

module Output_stream = struct
  type t = unit Ctypes_static.ptr
end

module Data = struct
  open C.Types

  let result_of_pm_error i : (unit, Portmidi_error.t) result =
    let open Pm_error in
    if Int.( = ) i no_error
    then Ok ()
    else if Int.( = ) i no_data
    then Ok ()
    else if Int.( = ) i got_data
    then Error `Got_data
    else if Int.( = ) i host_error
    then Error `Host_error
    else if Int.( = ) i invalid_device_id
    then Error `Invalid_device_id
    else if Int.( = ) i insufficient_memory
    then Error `Insufficient_memory
    else if Int.( = ) i buffer_too_small
    then Error `Buffer_too_small
    else if Int.( = ) i bad_ptr
    then Error `Bad_ptr
    else if Int.( = ) i bad_data
    then Error `Bad_data
    else if Int.( = ) i internal_error
    then Error `Internal_error
    else if Int.( = ) i buffer_max_size
    then Error `Buffer_max_size
    else failwithf "unknown PmError code: %d" i ()

  let pm_error_int i =
    let open Pm_error in
    match i with
    | `Got_data -> got_data
    | `Host_error -> host_error
    | `Invalid_device_id -> invalid_device_id
    | `Insufficient_memory -> insufficient_memory
    | `Buffer_too_small -> buffer_too_small
    | `Bad_ptr -> bad_ptr
    | `Bad_data -> bad_data
    | `Internal_error -> internal_error
    | `Buffer_max_size -> buffer_max_size

  let device_info_of_pdi pdi =
    let module PDI = PmDeviceInfo in
    let get x f = Ctypes.getf x f in
    { Device_info.struct_version_internal = get pdi PDI.struct_version;
      interface = get pdi PDI.interf;
      name = get pdi PDI.name;
      input = Int.( = ) (get pdi PDI.input) 1;
      output = Int.( = ) (get pdi PDI.output) 1;
      opened_internal = Int.( = ) (get pdi PDI.opened) 1
    }

  let default_sysex_buffer_size = default_sysex_buffer_size
end

let default_sysex_buffer_size = Data.default_sysex_buffer_size

module Functions = struct
  (*open Ctypes*)
  open C.Functions

  let initialize () = Data.result_of_pm_error (pm_initialize ())
  let terminate () = pm_terminate ()
  let count_devices () = pm_count_devices ()

  let get_device_info index =
    let di = pm_get_device_info index in
    if Ctypes.is_null di then None else Some (Data.device_info_of_pdi (Ctypes.( !@ ) di))

  let get_error_text err = pm_get_error_text (Data.pm_error_int err)
  let close stream = Data.result_of_pm_error (pm_close stream)
  let abort stream = Data.result_of_pm_error (pm_abort stream)

  let open_input ~device_id ~buffer_size =
    let open Ctypes in
    let stream = allocate (ptr void) null in
    let res = pm_open_input stream device_id null buffer_size null null in
    match Data.result_of_pm_error res with
    | Ok () -> Ok !@stream
    | Error err -> Error err

  let poll_input stream =
    match pm_poll stream with
    | 0 -> Ok false
    | 1 -> Ok true
    | x ->
      (match Data.result_of_pm_error x with
      | Ok () -> failwithf "poll_input: expected error here" ()
      | Error _ as e -> e)

  let read_input ~length stream =
    let open Ctypes in
    let buffer = allocate_n C.Types.PmEvent.t ~count:length in
    let retval = pm_read stream buffer (Int32.of_int_exn length) in
    if Int.( >= ) retval 0
    then
      let module PME = C.Types.PmEvent in
      let get x f = Ctypes.getf x f in
      let lst =
        let a = CArray.from_ptr buffer retval in
        List.map (CArray.to_list a) ~f:(fun pme ->
            { Portmidi_event.message = get pme PME.message; timestamp = get pme PME.timestamp })
      in
      Ok lst
    else (
      match Data.result_of_pm_error retval with
      | Ok () -> failwithf "read_input: expected error here" ()
      | Error _ as e -> e)

  let abort_input = abort
  let close_input = close

  let open_output ~device_id ~buffer_size ~latency =
    let open Ctypes in
    let stream = allocate (ptr void) null in
    let res = pm_open_output stream device_id null buffer_size null null latency in
    match Data.result_of_pm_error res with
    | Ok () -> Ok !@stream
    | Error _ as e -> e

  let write_output stream lst =
    let open Ctypes in
    let length = List.length lst in
    let a =
      let lst =
        let module PME = C.Types.PmEvent in
        List.map lst ~f:(fun portmidi_event ->
            let pme = make PME.t in
            setf pme PME.message portmidi_event.Portmidi_event.message;
            setf pme PME.timestamp portmidi_event.Portmidi_event.timestamp;
            pme)
      in
      let a = CArray.of_list C.Types.PmEvent.t lst in
      CArray.start a
    in
    let retval = pm_write stream a (Int32.of_int_exn length) in
    if Int.( = ) retval 0
    then Ok ()
    else (
      match Data.result_of_pm_error retval with
      | Ok () -> failwithf "write_output: expected error here" ()
      | Error _ as e -> e)

  let write_output_sysex ~when_ ~msg stream =
    let open Ctypes in
    let msg =
      let len = Array.length msg in
      let b = CArray.make char ~initial:'\x00' len in
      for i = 0 to pred len do
        CArray.set b i (Array.get msg i)
      done;
      CArray.start b
    in
    let res = pm_write_sysex stream (Int32.of_int_exn when_) msg in
    match Data.result_of_pm_error res with
    | Ok () -> Ok !@stream
    | Error _ as e -> e

  let abort_output = abort
  let close_output = close
end

include Functions
