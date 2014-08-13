#!/bin/bash

pushd /var/www/miq/vmdb/public

# Deploy Images
IMPATH="images/layout/"
FILES="RH-Product-Name.png VDCInternalBanner.jpg brand.svg login-screenground.jpg login-screen-logo.png"

for f in $FILES; do 
  cp $IMPATH/$f $IMPATH/${f}.back
  install $f $IMPATH/$f 
done

patch -p0 < login.patch
patch -p0 < template.patch

popd
