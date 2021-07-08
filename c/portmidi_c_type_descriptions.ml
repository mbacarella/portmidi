module Types (F : Ctypes.TYPE) = struct
  open Ctypes
  open F

  module Pm_error = struct
    let no_error = constant "pmNoError" int
    let no_data = constant "pmNoData" int
    let got_data = constant "pmGotData" int
    let host_error = constant "pmHostError" int
    let invalid_device_id = constant "pmInvalidDeviceId" int
    let insufficient_memory = constant "pmInsufficientMemory" int
    let buffer_too_small = constant "pmBufferTooSmall" int
    let bad_ptr = constant "pmBadPtr" int
    let bad_data = constant "pmBadData" int
    let internal_error = constant "pmInternalError" int
    let buffer_max_size = constant "pmBufferMaxSize" int
  end

  let default_sysex_buffer_size = constant "PM_DEFAULT_SYSEX_BUFFER_SIZE" int

  let pm_host_error_msg_len = constant "PM_HOST_ERROR_MSG_LEN" int

  module PmDeviceInfo = struct
    type t = [`PmDeviceInfo] structure
    let t : t typ = typedef (structure "`PmDeviceInfo") "PmDeviceInfo"
    let struct_version = field t "structVersion" int
    let interf = field t "interf" string_opt
    let name = field t "name" string_opt
    let input = field t "input" int
    let output = field t "output" int
    let opened = field t "opened" int
    let () = seal t
  end

  module PmEvent = struct
    type t = [`PmEvent] structure
    let t : t typ = typedef (structure "`PmEvent") "PmEvent"
    let pm_message = field t "message" int32_t
    let pm_timestamp = field t "timestamp" int32_t
    let () = seal t
  end
end
