#! /bin/bash
# Copyright 2011, Justin Makeig <justin-public+githug@makeig.com>
# 
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
# 
#        http://www.apache.org/licenses/LICENSE-2.0
# 
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
# A script to update MarkLogic home and data directory symlinks.
# This is useful for switching between multiple releases.
# The script assumes version numbers are appended to the end of the directory name separated by an underscore (_).
# It also assumes that the version numbers are the same on the home and data directories (e.g. _4.2-3.2 in both places).
# CAUTION: There are some checks to make sure it's not deleting data, but test it out somewhere safe first
# DISCLAIMER: This is not condoned or supported by MarkLogic Support or Engineering.
#
#
# Usage:
# ./ml.sh
# 
# Returns the current configuration
# App    /Users/username/Library/MarkLogic_5.0-x
# Data   /Users/username/Library/Application Support/MarkLogic/Data_5.0-x
#
# ./ml.sh 4.2-2
#
# Updates the symlinks using the version parameter and outputs the updated config 
#
# Stopping MarkLogic…
# Switched active server to:
# App    /Users/jmakeig/Library/MarkLogic_4.2-2
# Data   /Users/jmakeig/Library/Application Support/MarkLogic/Data_4.2-2
#
# ./ml.sh --unlink
# ./ml.sh -u
#
# Unlinks the existing softlinks. This is useful in preparation for a fresh install.
#
# Author: Justin Makeig <justin.makeig@marklogic.com>


# Existing configuration. These both must be symlinks
ML=~/Library/MarkLogic
DT=~/Library/Application\ Support/MarkLogic/Data

# Proposed configuration. These both must be directories.
MLNEW="$ML"_"$1"
DTNEW="$DT"_"$1"

# Handle the -u or --unlink parameters to remove the symlinks
for i in $*
do
	case $i in
	-u|--unlink)
	  echo "Stopping MarkLogic…"
    ~/Library/StartupItems/MarkLogic/MarkLogic stop > /dev/null 2>&1
	  unlink "$ML"
    unlink "$DT"
    exit 0
    ;;
  -l|--list)
    ls ~/Library | grep "^MarkLogic_"
    exit 0
    ;;
  -f|--forget)
    sudo pkgutil --forget com.marklogic.server
    exit 0
    ;;
	-h|--help)
	  echo "(no params): Displays the current symlink configuration."
	  echo "X.X-X: Creates new symlinks to the version specified."
	  echo "-l or --list: List the available version targets, i.e. the number you'd pass in to update the symlinks."
	  echo "-u or --unlink: Unlink the existing symlinks. Does not use rm for anything."
	  echo "-h or --help: Display this help."
    exit 0
    ;;
  *)
		;;
  	esac
done

if [ $# -eq 0 ]
then
  echo -e "App\t" `readlink "$ML"`
  echo -e "Data\t" `readlink "$DT"`
else
  echo "Stopping MarkLogic…"
  ~/Library/StartupItems/MarkLogic/MarkLogic stop > /dev/null 2>&1
  if [ -d "$MLNEW" ] && [ -d "$DTNEW" ] # && [ -h "$ML" ] && [ -h "$DT" ]
  then
    #echo "Both $ML and $DT are symlinks and $MLNEW and $DTNEW are directories."
    ln -sfh "$MLNEW" "$ML" 
    ln -sfh "$DTNEW" "$DT" 
    echo "Switched active server to:"
    # Call myself recursively to display the new state
    $0
  else 
    echo "Both $ML and $DT must be symlinks. $MLNEW and $DTNEW must also be directories."
    exit 1
  fi
fi

# unlink "$ML"
# unlink "$DT"

