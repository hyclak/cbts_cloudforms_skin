#!/bin/bash

rpm -q patch >/dev/null
if [ $? -ne 0 ]; then
  echo "patch command is not installed, updating"
  yum -y install patch
fi

sourcedir=`pwd`
pushd /var/www/miq/vmdb/public

# Deploy Images
IMPATH="images/layout/"
FILES="RH-Product-Name.png VDCInternalBanner.jpg brand.svg login-screen-background.jpg login-screen-logo.png"

for f in $FILES; do 
  cp $IMPATH/$f $IMPATH/${f}.back
  install $sourcedir/$f $IMPATH/$f 
done

patch -p0 < $sourcedir/login.patch
patch -p0 < $sourcedir/template.patch

popd
