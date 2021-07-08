open! Core_kernel
open! [@warning "-66"] No_polymorphic_compare

module Device_info = struct
  type t =
    { interface : string option
    ; name : string option
    ; input : bool
    ; output : bool
    ; struct_version_internal : int
    ; opened_internal : bool }
  [@@deriving sexp, fields]
end

(*
let char_array_as_string a =
  let len = Array.length a in
  let b = Buffer.create len in
  try
    for i = 0 to len -1 do
      let c = Array.get a i in
      if Char.(=) c '\x00'
      then raise Exit
      else Buffer.add_char b c
    done;
    Buffer.contents b
  with Exit -> Buffer.contents b
*)

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
   | `Buffer_max_size ]
 [@@deriving sexp]
end

module Input_stream = struct
  type t = unit Ctypes_static.ptr Ctypes.ptr
end

module Output_stream = struct
  type t = unit Ctypes_static.ptr Ctypes.ptr
end

module Data = struct
  open C.Types

  let result_of_pm_error i : (unit, Portmidi_error.t) result =
    let open Pm_error in
    if Int.(=) i no_error then Ok ()
    else if Int.(=) i no_data then Ok ()
    else if Int.(=) i got_data then Error `Got_data
    else if Int.(=) i host_error then Error `Host_error
    else if Int.(=) i invalid_device_id then Error `Invalid_device_id
    else if Int.(=) i insufficient_memory then Error `Insufficient_memory
    else if Int.(=) i buffer_too_small then Error `Buffer_too_small
    else if Int.(=) i bad_ptr then Error `Bad_ptr
    else if Int.(=) i bad_data then Error `Bad_data
    else if Int.(=) i internal_error then Error `Internal_error
    else if Int.(=) i buffer_max_size then Error `Buffer_max_size
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
    { Device_info.struct_version_internal = get pdi PDI.struct_version
    ; interface = get pdi PDI.interf
    ; name = get pdi PDI.name
    ; input = Int.(=) (get pdi PDI.input) 1
    ; output = Int.(=) (get pdi PDI.output) 1
    ; opened_internal = Int.(=) (get pdi PDI.opened) 1 }

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
    if Ctypes.is_null di
    then None
    else Some (Data.device_info_of_pdi (Ctypes.( !@ ) di))

  let get_error_text err =
    pm_get_error_text (Data.pm_error_int err)

  let open_input ~device_id ~buffer_size =
    let open Ctypes in
    let stream = allocate (ptr void) null in
    let res = pm_open_input stream device_id null buffer_size null null in
    match Data.result_of_pm_error res with
    | Ok () -> Ok stream
    | Error err -> Error err

  let open_output ~device_id ~buffer_size ~latency =
    let open Ctypes in
    let stream = allocate (ptr void) null in
    let res = pm_open_output stream device_id null buffer_size null null latency in
    match Data.result_of_pm_error res with
    | Ok () -> Ok stream
    | Error err -> Error err

  let close stream = Data.result_of_pm_error (pm_close stream)
  let close_input = close
  let close_output = close
end

include Functions
