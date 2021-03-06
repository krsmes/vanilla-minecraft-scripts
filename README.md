> These scripts were written for OSX but may be portable to Linux

> `eventtail.gsh` is a Groovy script and requires Java/Groovy to be installed on the system

## Usage

Clone this repo into a `bin` folder inside your minecraft server folder:
```
git clone https://... bin
```

Now from your minecraft server folder you can run commands like:
```
bin/mc.sh start
bin/mc.sh stop
bin/mc.sh taillog
bin/mc.sh send say yo
```

See `library.sh` for a complete list of available functions to call.

## `eventtail.gsh`

The `eventtail.gsh` script is an example Groovy script that can read
Minecraft's nbt data file format (for both world/level.dat and the 
world/playerdata files), as well as send commands to Minecraft using
the `screen` command (assuming Minecraft was started using the `mc.sh`
script).

## `loop.sh`

The `loop.sh` script is an example usage of both the `library.sh` and 
the `eventtail.gsh` to generate a new world every 3 hours, but carry a
player's inventory forward from world to world.

## Resources

1. Groovy: http://www.groovy-lang.org/documentation.html
    * Groovy Shebang: http://docs.groovy-lang.org/latest/html/documentation/#_shebang_line
    * Grape/Grab: http://docs.groovy-lang.org/latest/html/documentation/grape.html
1. Java NBT library: https://github.com/flow/nbt
1. screen: https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/screen.1.html
    * `stuff`: http://stackoverflow.com/questions/13829310/shell-gnu-screen-x-stuff-problems/13870705
1. bash libraries: https://bash.cyberciti.biz/guide/Shell_functions_library
1. Minecraft commands: http://minecraft.gamepedia.com/Commands
