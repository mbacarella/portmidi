open Ctypes

module Types = Portmidi_c_types

module Functions (F : Ctypes.FOREIGN) = struct
  open F

  let pm_initialize = foreign "Pm_Initialize" (void @-> returning int)

  let pm_terminate = foreign "Pm_Terminate" (void @-> returning void)

  let pm_count_devices = foreign "Pm_CountDevices" (void @-> returning int)

  let pm_get_device_info =
    foreign "Pm_GetDeviceInfo" (int @-> returning (ptr Types.PmDeviceInfo.t))

  let pm_get_error_text =
    foreign "Pm_GetErrorText" (int @-> returning string_opt)

  let pm_open_input =
    foreign "Pm_OpenInput"
      ((ptr (ptr void)) @-> int @-> (ptr void) @-> int32_t
       @-> (ptr void) @-> (ptr void) @-> returning int)

  let pm_open_output =
    foreign "Pm_OpenOutput"
      ((ptr (ptr void)) @-> int @-> (ptr void) @-> int32_t
       @-> (ptr void) @-> (ptr void) @-> int32_t @-> returning int)

  let pm_close = foreign "Pm_Close" ((ptr (ptr void)) @-> returning int)
end
