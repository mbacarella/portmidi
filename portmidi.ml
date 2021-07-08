open! Base

module Device_info = struct
  type t =
    { interface : string
    ; name : string
    ; input : bool
    ; output : bool
    ; struct_version_internal : int
    ; opened_internal : bool }
  [@@deriving sexp, fields]
end

module Constants = struct
  open C.Types

  let result_of_int i =
    let open Pm_error in
    if Int.(=) i no_error then Ok ()
    else if Int.(=) i no_data then Ok ()
    else if Int.(=) i got_data then Error `Got_data
    else if Int.(=) i host_error then Error `Host_error
    else if Int.(=) i invalid_device_id then Error `Invalid_device_id
    else if Int.(=) i insufficient_memory then Error `Insufficient_memory
    else if Int.(=) i buffer_too_small then Error `Buffer_too_small
    else failwith (Printf.sprintf "unknown PmError code: %d" i)

  let device_info_of_pdi pdi =
    let module PDI = Portmidi_device_info in
    { Device_info.struct_version_internal = pdi.PDI.struct_version
    ; interface = pdi.PDI.interf
    ; name = pdi.PDI.name
    ; input = Int.(=) pdi.PDI.input 1
    ; output = Int.(=) pdi.PDI.output 1
    ; opened_internal = Int.(=) pdi.PDI.opened 1

  let default_sysex_buffer_size = default_sysex_buffer_size
end

module Functions = struct
  (*open Ctypes*)
  open C.Functions

  let initialize () =
    Constants.result_of_int (pm_initialize ())
  let terminate () = pm_terminate
  let count_devices = pm_count_devices
  let get_device_info index =
    let di = pm_get_device_info index in
    Constnats.device_info_of_pdi di
end

include Functions
