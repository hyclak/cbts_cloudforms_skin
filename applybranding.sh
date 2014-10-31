#!/bin/bash
#
# Applies CBTS branding to Cloud Forms 3.1 (cfme 5.3)
#
# Version History
#    0.1 - mrh - Initial Release

rpm -q patch >/dev/null
if [ $? -ne 0 ]; then
  echo "patch command is not installed. Installing patch rpm."
  yum -y install patch
fi

sourcedir=`pwd`
pushd /var/www/miq/vmdb

# Deploy Images
echo "Deploying Images"

# Backup the default branding if it hasn't been done
if [ ! -f assets/images/layout/brand.svg ]; then
  mv assets/images/layout/brand.svg assets/images/layout/brand.svg.orig
fi

# Deploy CBTS Brand in upper left corner
install -m 644 $sourcedir/brand.svg assets/images/layout/brand.svg

# Deploy CBTS Header Banner
install -m 644 $sourcedir/VDCInternalBanner.jpg public/images/layout/VDCInternalBanner.jpg

# Patch the CSS
echo "Patching CSS files"
patch -p0 < $sourcedir/login.diff
patch -p0 < $sourcedir/header.diff

# Patch the UI Constants (to make the top border Orange by default)
echo "Patching UI Constants"
patch -p0 < $sourcedir/constants.diff

# Rebuild assets in Cloud Forms
echo "Rebuilding UI Assets"
RAILS_ENV=production rake assets:clean

echo "Branding complete"
popd