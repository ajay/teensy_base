# Teensy base setup

## Installation / Environment

#### Dependencies:
- `arm-none-eabi-gcc`
- `teensy-loader-cli`

#### Installation
- `sudo add-apt-repository ppa:team-gcc-arm-embedded/ppa`
- `sudo apt update`
- `sudo apt install gcc-arm-embedded teensy-loader-cli`

- Note: do not use this package from Ubuntu 18.04 PPA: `gcc-arm-none-eabi`
    - There is a bug that causes linker errors

- In order for serial comm to work properly:
    - Get udev rules from here: https://www.pjrc.com/teensy/49-teensy.rules
    - Copy udev rules to `/etc/udev/rules.d/`:
        `sudo cp 49-teensy.rules /etc/udev/rules.d/`

#### Versions that were used
- `arm-none-eabi-gcc`: 7.3.1 20180622
- `teensy-loader-cli`: 2.1-1
