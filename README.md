# minui-pico-8-pak

A pak wrapping PICO-8, a fantasy video game console.

## Requirements

This pak is designed and tested on the following MinUI Platforms and devices:

- `tg5040`: Trimui Brick (formerly `tg3040`)

Use the correct platform for your device.

## Installation

> [!IMPORTANT]
> This emulator pack requires a paid copy of Pico-8. Please purchase this from [the official Pico-8 page](https://www.lexaloffle.com/pico-8.php). No Pico-8 binaries will be provided otherwise.

1. Mount your MinUI SD card.
2. Download the latest release from Github. It will be named `PICO.pak.zip`.
3. Copy the zip file to `/Emus/$PLATFORM/PICO.pak.zip`.
4. Extract the zip in place, then delete the zip file.
5. Confirm that there is a `/Emus/$PLATFORM/N64.pak/launch.sh` file on your SD card.
6. Create a folder at `/Roms/Pico-8 (PICO)` and place your roms in this directory.
7. Download the `Raspberry PI` Pico-8 zip. As of this time of writing, it will be `pico-8_0.2.6b_raspi.zip`, available from the Lexaloffle site.
8. Extract the `pico-8_0.2.6b_raspi.zip` zip and place the `pico8`, `pico8_64`, and `pico8.dat` in the `/Bios/PICO` folder on your SD card.
9. Unmount your SD Card and insert it into your MinUI device.

## Usage

Browse to `Pico-8` and press `A` to play a game.

The following filetypes are supported:

- Native: `.p8`

### Exiting a game

To exit a game:

- press the `Start` button
- select `Options`
- select `shutdown Pico-8`

### In-Game saves

Any game that creates in-game saves will save these to `$SDCARD_PATH/.userdata/shared/Pico-8-native`.

### Splore

> [!NOTE]
> Splore requires an internet connection. The [Wifi.pak](https://github.com/josegonzalez/minui-wifi-pak/) can be used to connect to your network to provide Splore with an internet connection.

To run splore, create a `Splore.p8` file in `/Roms/Pico-8 (PICO)` (it can be empty). Choosing this game in MinUI will launch the Splore UI. If no wifi connection is available, Splore will fail to start.

To exit Splore, choose a game and follow the normal process of exiting a game.

A sample `Splore.p8` file is included in the base of this repository.

### Debug Logging

To enable debug logging, create a file named debug in `$SDCARD_PATH/.userdata/$PLATFORM/N64-mupen64plus` folder. Logs will be written to the`$SDCARD_PATH/.userdata/$PLATFORM/logs/` folder.
