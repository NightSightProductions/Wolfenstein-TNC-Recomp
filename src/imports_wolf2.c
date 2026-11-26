// Imports specific to Wolfenstein II: The New Colossus.
#include <string.h>
#include "rt.h"

// amd_ags_x64.dll (AMD GPU Services 5.x). The engine uses it for AMD-only driver extensions (shader intrinsics,
// crossfire); on a Mac there is no AMD driver, so agsInit fails the way it does on an NVIDIA/Intel PC and the
// engine carries on without it.
//   AGSReturnCode agsInit(AGSContext **context, const AGSConfiguration *config, AGSGPUInfo *gpuInfo)
#define AGS_SUCCESS 0
#define AGS_ERROR_LEGACY_DRIVER 7   // AGS 5: "returned if driver doesn't support AGS"
void wolf2_cloud_log(void);
void I_amd_ags_x64_dll_agsInit(CPU *c) {
    // one of the first calls after the log is open: the save-folder setup (cloud_wolf2.c, which runs before the log
    // exists) reports here
    wolf2_cloud_log();
    static int logged;
    if (!logged++) rt_log("[ags] agsInit: no AMD driver\n");
    if (A0) *(uint64_t *)PTR(A0) = 0;
    RET(AGS_ERROR_LEGACY_DRIVER);
}
void I_amd_ags_x64_dll_agsDeInit(CPU *c) { RET(AGS_SUCCESS); }
