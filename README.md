# Teensy base setup

## Installation / Environment

#### Dependencies:
- `teensy-loader-cli`
- `arm-none-eabi-gcc`

#### Installation
- `sudo add-apt-repository ppa:team-gcc-arm-embedded/ppa`
- `sudo apt update`
- `sudo apt install gcc-arm-embedded teensy-loader-cli`

- Note: do not use this package from Ubuntu 18.04 PPA: `gcc-arm-none-eabi`
    - There is a bug that causes linker errors

#### Versions that were used
- `teensy-loader-cli`: 2.1-1
- `arm-none-eabi-gcc`: 7.3.1 20180622
