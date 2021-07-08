module Constants = struct
  open C.Types

  let default_sysex_buffer_size = default_sysex_buffer_size
end

module Functions = struct
  (*open Ctypes*)
  open C.Functions

  let initialize = pm_initialize
  let terminate = pm_terminate
  let count_devices = pm_count_devices
end

include Functions
