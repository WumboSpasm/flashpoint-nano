# Flashpoint Nano
Flashpoint Nano is a Wine-less, Docker-less, minimal-dependency proof-of-concept command-line Flashpoint launcher for Linux built entirely using shell scripts.

By default, only two platforms are supported: Flash (using [Ruffle](https://ruffle.rs/)) and HTML5 (using [Pale Moon](https://www.palemoon.org/)). Their scripts are designed to automatically download the latest version of their respective software when it is available.

## Usage
Make sure that the `curl`, `tar`, `sqlite3`, and `unxz` utilities are available on your system before use. Afterwards, open the terminal in the directory containing flashpoint.sh and run the following command: `./flashpoint.sh <entry-id> [addapp-id]`

You can find the ID of your desired entry by using an online search tool such as the [Flashpoint Database](https://flashpointproject.github.io/flashpoint-database/). The additional app ID is optional.

## Configuration
The launcher is designed to be highly extensible; new platforms can be added by simply writing a launch script and updating your `config.sh` file accordingly.

Overrides are used to replace the Windows-targeted application paths with more appropriate equivalents. It compares the entry's launch command, application path, and platform fields (in that order) to the RegEx-capable override definitions in `config.sh`, and executes the desired launch script if there is a match.
