#! /bin/bash
# -x
# Copyright 2011, Justin Makeig <justin-public+github@makeig.com>
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

ML=~/Library/MarkLogic
DT=~/Library/Application\ Support/MarkLogic/Data
LOGIN=jmakeig


# If there is no date provided, use today
if [ -z "$2" ]
then
    NIGHTLY=`date "+%Y%m%d"`
else
    NIGHTLY=$2    
fi

VER="$1"-"$NIGHTLY"
URL=http://root.marklogic.com/nightly/builds/macosx/osx-intel64-51-build.marklogic.com/HEAD/pkgs."$NIGHTLY"/MarkLogic-"$VER"-x86_64.dmg
# URL=http://developer.marklogic.com/download/binaries/4.2/MarkLogic-4.2-6-x86_64.dmg
# URL=http://community.marklogic.com/download/binaries/5.0/MarkLogic-5.0-3-x86_64.dmg

echo "Shutting down and unlinking a previous installation…"
~/bin/ml.sh -u

echo Downloading $URL
curl --basic -u $LOGIN  -o ~/Downloads/MarkLogic-"$VER"-x86_64.dmg $URL

# TODO: Take the disk image as a parameter and parse out the version number
hdiutil attach ~/Downloads/MarkLogic-"$VER"-x86_64.dmg
installer -pkg /Volumes/MarkLogic/MarkLogic-"$VER"-x86_64.pkg -target /
hdiutil detach /Volumes/MarkLogic

echo "Moving the default installation to version-specific directories…"
# Server: Create a version-speicif folder and a soft link
mv "$ML" "$ML"_"$VER"
ln -s "$ML"_"$VER" "$ML"

# Data: Create a version-speicif folder and a soft link
mv "$DT" "$DT"_"$VER"
ln -s "$DT"_"$VER" "$DT"

~/bin/ml.sh "$VER"
