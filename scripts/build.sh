#!/bin/bash
#
# Builds "Wolfenstein II The New Colossus.app" from YOUR copy of Wolfenstein II: The New Colossus (Windows
# version, Steam). Nothing from the game is stored in this repository; everything is generated locally from
# your install, and the app reads the game data from your install at run time.
#
# Usage: scripts/build.sh [path/to/Wolfenstein.II.The.New.Colossus]   (the folder with NewColossus_x64vk.exe)
#
# Progress lines start with "==> [n/6]" so an installer can follow along.

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
die() { echo "error: $*" >&2; exit 1; }
step() { echo "==> [$1/6] $2"; }

FOLDER="Wolfenstein.II.The.New.Colossus"
find_game() {
    local c
    for c in \
        "$HOME/Library/Application Support/Steam/steamapps/common/$FOLDER" \
        "$HOME/Library/Application Support/CrossOver/Bottles/"*"/drive_c/Program Files (x86)/Steam/steamapps/common/$FOLDER" \
        "$HOME/Library/Containers/com.isaacmarovitz.Whisky/Bottles/"*"/drive_c/Program Files (x86)/Steam/steamapps/common/$FOLDER"; do
        [[ -f "$c/NewColossus_x64vk.exe" ]] && { echo "$c"; return; }
    done
}
GAME="${1:-$(find_game)}"
[[ -n "$GAME" ]] || die "the game was not found. Pass the folder that contains NewColossus_x64vk.exe"

# The Steam release this project is written against
SHA_EXE="68e6c21a97c2a0824ff75961a771605dacbd73f17e33e8e7265741535a3818c3"          # as shipped (SteamStub v3.1)
SHA_UNWRAPPED="e273df14b6380db6de519ee47677117ab127d496002da3c775b38cca48b03f69"    # after tools/unwrap_steamstub.py
SHA_OODLE="4c3dcfebb2bb59650690feb4c63d68a5838c37c0ff233c2445269fef0c5a40d0"        # oo2core_5_win64.dll
SHA_BINK="05bdd56e088798d2e09a8ea912fadaea821ffea2b328f89e1f525f9859b36e06"         # bink2w64.dll

step 1 "Checking requirements"
for t in clang make python3 codesign ar openssl; do
    command -v "$t" >/dev/null 2>&1 || die "'$t' was not found. Install Apple's Command Line Tools: xcode-select --install"
done
[[ "$(uname -m)" == "arm64" ]] || die "this build targets Apple Silicon Macs"

step 2 "Verifying your copy of the game"
check() {
    [[ -f "$1" ]] || die "$1 was not found"
    local sha; sha="$(shasum -a 256 "$1" | awk '{print $1}')"
    [[ "$sha" == "$2" ]] || die "$1 is not from the supported Steam release (SHA-256 $sha). Make sure the game is fully updated and not modified."
}
check "$GAME/NewColossus_x64vk.exe" "$SHA_EXE"
check "$GAME/oo2core_5_win64.dll" "$SHA_OODLE"
check "$GAME/bink2w64.dll" "$SHA_BINK"

step 3 "Preparing the translator"
[[ -x "$ROOT/.venv/bin/python" ]] || python3 -m venv "$ROOT/.venv"
"$ROOT/.venv/bin/python" -m pip install --quiet --disable-pip-version-check "capstone==5.0.6" "lief==0.16.6"

cd "$ROOT"
mkdir -p build
python3 -I tools/unwrap_steamstub.py "$GAME/NewColossus_x64vk.exe" build/NewColossus_x64vk.unwrapped.exe
check build/NewColossus_x64vk.unwrapped.exe "$SHA_UNWRAPPED"
ln -sf build/NewColossus_x64vk.unwrapped.exe orig.exe
ln -sf "$GAME/oo2core_5_win64.dll" orig_oodle.dll
ln -sf "$GAME/bink2w64.dll" orig_bink.dll

step 4 "Translating the game's code to C"
make -s gen
make -s gen-dll
make -s gen-bink

step 5 "Compiling (this takes several minutes)"
make -s -j"$(sysctl -n hw.ncpu)" boot

step 6 "Packaging the app"
if [[ -d "$ROOT/prebuilt/kosmickrisp" ]]; then
    rm -rf build/kosmickrisp && cp -R "$ROOT/prebuilt/kosmickrisp" build/kosmickrisp
elif [[ ! -d build/kosmickrisp ]]; then
    echo "note: no KosmicKrisp build (make kosmickrisp); the app will use a system install (/usr/local/share/vulkan/icd.d)"
fi
make -s app
mkdir -p "$HOME/Library/Application Support/wolf2-recomp"
printf '%s\n' "$GAME" > "$HOME/Library/Application Support/wolf2-recomp/game-dir.txt"
echo "Built: $ROOT/build/Wolfenstein II The New Colossus.app"
