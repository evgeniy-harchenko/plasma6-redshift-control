#!/bin/bash

DIR="$( dirname "${BASH_SOURCE[0]}" )"
CURRDIR=$PWD
cd $DIR
rm -r buildWidget
mkdir buildWidget

#compile translations used inside the plasmoid
pushd po
./build.sh
popd

cd package


VERSION=$(cat ./metadata.json | jq -r '.KPlugin.Version')
#  )
#
# ( grep \"Version\" ./metadata.json | cut -d':' -f 2 )"
echo $VERSION

zip  -r "../buildWidget/plasma6-redshift-control-$VERSION.plasmoid" * --exclude \.git\* --exclude *.bak

rm -dr contents/locale
