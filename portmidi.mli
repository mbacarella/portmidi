val default_sysex_buffer_size : int

module Device_info : sig
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

module Portmidi_error : sig
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
  [@@deriving sexp]
end

val message_status : int32 -> int32
val message_data1 : int32 -> int32
val message_data2 : int32 -> int32

module Portmidi_event : sig
  type t =
    { message : int32;
      timestamp : int32
    }
  [@@deriving sexp, fields]

  val create : status:char -> data1:char -> data2:char -> timestamp:int32 -> t
end

module Input_stream : sig
  type t
end

module Output_stream : sig
  type t
end

val initialize : unit -> (unit, Portmidi_error.t) result
val terminate : unit -> unit
val count_devices : unit -> int
val get_device_info : int -> Device_info.t option
val get_error_text : Portmidi_error.t -> string option
val open_input : device_id:int -> buffer_size:int32 -> (Input_stream.t, Portmidi_error.t) result
val poll_input : Input_stream.t -> (bool, Portmidi_error.t) result
val read_input : length:int -> Input_stream.t -> (Portmidi_event.t list, Portmidi_error.t) result
val abort_input : Input_stream.t -> (unit, Portmidi_error.t) result
val close_input : Input_stream.t -> (unit, Portmidi_error.t) result

val open_output
  :  device_id:int ->
  buffer_size:int32 ->
  latency:int32 ->
  (Output_stream.t, Portmidi_error.t) result

val write_output : Output_stream.t -> Portmidi_event.t list -> (unit, Portmidi_error.t) result

val write_output_sysex
  :  when_:int ->
  msg:char array ->
  Output_stream.t ->
  (unit, Portmidi_error.t) result

val abort_output : Output_stream.t -> (unit, Portmidi_error.t) result
val close_output : Output_stream.t -> (unit, Portmidi_error.t) result
