open Ctypes

module Types = Portmidi_c_types

module Functions (F : Ctypes.FOREIGN) = struct
  open F

  let pm_initialize = foreign "Pm_Initialize" (void @-> returning int)
  let pm_terminate = foreign "Pm_Terminate" (void @-> returning void)
end
