#!/bin/bash
#
# Applies CBTS branding to CloudForms 3.2 (cfme 5.4)
#
# Version History
#    0.1 - mrh - Initial Release
#    0.2 - mrh - evm:compile_assets task doesn't like .orig files to be created, moving to separate backup dir
#    0.3 - mrh - Update to CloudForms 3.2

#rpm -q patch >/dev/null
#if [ $? -ne 0 ]; then
#  echo "patch command is not installed. Installing patch rpm."
#  yum -y install patch
#fi

if [ ! -d backup ]; then
  mkdir backup
fi

sourcedir=`pwd`
pushd /var/www/miq/vmdb

# Deploy Images
echo "Deploying Images"

# Backup the default branding if it hasn't been done
if [ ! -f ${sourcedir}/backup/brand.svg.orig ]; then
  mv productization/assets/images/brand.svg ${sourcedir}/backup/brand.svg.orig
fi

# Deploy CBTS Brand in upper left corner
install -m 644 $sourcedir/brand.svg productization/assets/images/brand.svg

# Deploy CBTS Header Banner
# TODO: This was handled in header.css.erb but is now done in patternfly. Need to figure out how to override that.
# install -m 644 $sourcedir/VDCInternalBanner.jpg public/images/layout/VDCInternalBanner.jpg

# Rebuild assets in Cloud Forms
echo "Rebuilding UI Assets"
rake evm:compile_assets

echo "Branding complete"
popd
