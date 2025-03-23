#!/bin/sh
PAK_DIR="$(dirname "$0")"
PAK_NAME="$(basename "$PAK_DIR")"
PAK_NAME="${PAK_NAME%.*}"
[ -f "$USERDATA_PATH/Pico-8-native/debug" ] && set -x

rm -f "$LOGS_PATH/$PAK_NAME.txt"
exec >>"$LOGS_PATH/$PAK_NAME.txt"
exec 2>&1

echo "$0" "$*"
cd "$PAK_DIR" || exit 1
mkdir -p "$USERDATA_PATH/Pico-8-native"

architecture=arm
if uname -m | grep -q '64'; then
    architecture=arm64
fi

export EMU_DIR="$PAK_DIR/pico8"
export HOME="$USERDATA_PATH/Pico-8-native"
export LD_LIBRARY_PATH="$EMU_DIR/lib:$PAK_DIR/lib/$PLATFORM:$PAK_DIR/lib/$architecture:$LD_LIBRARY_PATH"
export PATH="$EMU_DIR:$PAK_DIR/bin/$PLATFORM:$PAK_DIR/bin/$architecture:$PAK_DIR/bin:$PATH"
export XDG_CONFIG_HOME="$USERDATA_PATH/Pico-8-native/config"
export XDG_DATA_HOME="$USERDATA_PATH/Pico-8-native/data"

export GAMESETTINGS_DIR="$USERDATA_PATH/Pico-8-native/game-settings/$ROM_NAME"
export SCREENSHOT_DIR="$SDCARD_PATH/Screenshots"

launch_cart() {
    ROM_PATH="$1"
    cp -f "$PAK_DIR/controllers/$PLATFORM.txt" "$HOME/sdl_controllers.txt"
    cp -f "$PAK_DIR/config/$PLATFORM.txt" "$HOME/config.txt"

    echo performance >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

    pico_bin="pico8_dyn"
    if [ "$architecture" = "arm64" ]; then
        pico_bin="pico8_64"
    fi

    cart_path="$(dirname "$ROM_PATH")"

    case "$ROM_PATH" in
    *"Splore"* | *"splore"*)
        if [ "$PLATFORM" = "tg5040" ]; then
            "$pico_bin" -preblit_scale 3 -splore -joystick 0 -root_path "$cart_path" -home "$HOME" -desktop "$SDCARD_PATH/Screenshots"
        else
            "$pico_bin" -splore -joystick 0 -root_path "$cart_path" -home "$HOME" -desktop "$SDCARD_PATH/Screenshots"
        fi
        sync
        ;;
    *)
        if [ "$PLATFORM" = "tg5040" ]; then
            "$pico_bin" -preblit_scale 3 -run "$ROM_PATH" -joystick 0 -root_path "$cart_path" -home "$HOME" -desktop "$SDCARD_PATH/Screenshots"
        else
            "$pico_bin" -run "$ROM_PATH" -joystick 0 -root_path "$cart_path" -home "$HOME" -desktop "$SDCARD_PATH/Screenshots"
        fi
        sync
        ;;
    esac
}

verify_platform() {
    allowed_platforms="tg5040 rg35xxplus rg35xx"
    if ! echo "$allowed_platforms" | grep -q "$PLATFORM"; then
        show_message "$PLATFORM is not a supported platform" 2
        return 1
    fi

    if ! command -v minui-presenter >/dev/null 2>&1; then
        show_message "minui-presenter not found" 2
        return 1
    fi

    if ! command -v wget >/dev/null 2>&1; then
        show_message "wget not found" 2
        return 1
    fi
}

install_pico_files() {
    pico_bin="pico8_dyn"
    if [ "$ARCHITECTURE" = "arm64" ]; then
        pico_bin="pico8_64"
    fi

    if [ ! -f "$EMU_DIR/bin/$pico_bin" ]; then
        test -f "$SDCARD_PATH/$pico_bin" && mv -f "$SDCARD_PATH/$pico_bin" "$EMU_DIR/bin/$pico_bin"
    fi

    if [ ! -f "$EMU_DIR/pico8.dat" ]; then
        test -f "$SDCARD_PATH/pico8.dat" && mv -f "$SDCARD_PATH/pico8.dat" "$EMU_DIR/pico8.dat"
    fi

    if [ ! -f "$EMU_DIR/bin/$pico_bin" ] || [ ! -f "$EMU_DIR/pico8.dat" ]; then
        minui-presenter --message "Missing $pico_bin or pico8.dat. Please copy them to the root of your SD card." --timeout 4
        return 1
    fi
}

show_message() {
    message="$1"
    seconds="$2"

    if [ -z "$seconds" ]; then
        seconds="forever"
    fi

    killall minui-presenter >/dev/null 2>&1 || true
    echo "$message" 1>&2
    if [ "$seconds" = "forever" ]; then
        minui-presenter --message "$message" --timeout -1 &
    else
        minui-presenter --message "$message" --timeout "$seconds"
    fi
}

cleanup() {
    rm -f /tmp/stay_awake
    killall minui-presenter >/dev/null 2>&1 || true
}

main() {
    echo "1" >/tmp/stay_awake
    trap "cleanup" EXIT INT TERM HUP QUIT

    if [ "$PLATFORM" = "tg3040" ] && [ -z "$DEVICE" ]; then
        export DEVICE="brick"
        export PLATFORM="tg5040"
    fi

    env | sort
    sleep 1

    if ! verify_platform; then
        return 1
    fi

    if ! install_pico_files; then
        return 1
    fi

    # run the power-button-pressed script if it exists for this platform
    if command -v power-button-pressed >/dev/null; then
        power-button-monitor &
    fi

    ROM_PATH="$1"
    launch_cart "$ROM_PATH"

    # handle the power-button pressed event
    if [ -f /tmp/shutdown_from_pak ]; then
        AUTO_RESUME_FILE="$SHARED_USERDATA_PATH/.minui/auto_resume.txt"
        echo "$ROM_PATH" >"$AUTO_RESUME_FILE"
        sync
        rm /tmp/minui_exec
        shutdown
        while :; do
            sleep 1
        done
    fi

    kill "$!"
}

main "$@"
