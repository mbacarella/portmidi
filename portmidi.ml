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

module Data = struct
  open C.Types

  let result_of_pm_error i =
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

  let device_info_of_pdi pdi =
    let module PDI = Portmidi_device_info in
    let get x f = Ctypes.getf x f in
    { Device_info.struct_version_internal = get pdi PDI.struct_version
    ; interface = get pdi PDI.interf
    ; name = get pdi PDI.name
    ; input = Int.(=) (get pdi PDI.input) 1
    ; output = Int.(=) (get pdi PDI.output) 1
    ; opened_internal = Int.(=) (get pdi PDI.opened) 1 }

  let default_sysex_buffer_size = default_sysex_buffer_size
end

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
end

include Functions
