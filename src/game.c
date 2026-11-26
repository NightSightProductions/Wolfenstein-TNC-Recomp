// Wolfenstein II: The New Colossus settings for Recomp-Framework (see framework/runtime/game.h).
#include "game.h"

const RtGame rt_game = {
    .name = "Wolfenstein II: The New Colossus",
    .exe = "NewColossus_x64vk.exe",
    .win_dir = "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Wolfenstein.II.The.New.Colossus",
    .data_name = "wolf2-recomp",
    .log_name = "Wolf2-recomp",
    .env_prefix = "WOLF2",
    .steam_folder = "Wolfenstein.II.The.New.Colossus",
    .steam_app_id = 612880,
    .relaunch_prefix = "NewColossus",
    .extra_args = NULL,
    .cloud_save_dir = NULL,     // TODO: Auto-Cloud saves under Saved Games\MachineGames, as in Wolfenstein-TOB-Recomp
    .cloud_prefix = NULL,
    .computer_name = "MAC",
    .pick_folder_msg = "Choose your Wolfenstein II: The New Colossus game folder: the one that contains NewColossus_x64vk.exe.",
    // the DRM-free copy made at build time by tools/unwrap_steamstub.py and bundled into the app
    .image = "NewColossus_x64vk.exe",
};
