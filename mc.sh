#!/bin/bash

mc_sh_dir=`dirname "${BASH_SOURCE[0]}"`

##
## This script uses 'screen' to start and control a vanilla
## minecraft server.
##
## See library.sh for a list of functions that can be called.
##
## This script assumes it is running from the directory 
## containing the 'world' folder (changeable by setting MC_DIR)
## and assumes the server jar is name minecraft_server.jar.
##

# library.sh and this script should be in the same directory
source "$mc_sh_dir/library.sh"  

$1 $2 $3 $4 $5 $6 $7 $8 $9
