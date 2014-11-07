#!/bin/bash
#
# Applies CBTS branding to Cloud Forms 3.1 (cfme 5.3)
#
# Version History
#    0.1 - mrh - Initial Release
#    0.2 - mrh - evm:compile_assets task doesn't like .orig files to be created, moving to separate backup dir

rpm -q patch >/dev/null
if [ $? -ne 0 ]; then
  echo "patch command is not installed. Installing patch rpm."
  yum -y install patch
fi

if [ ! -d backup ]; then
  mkdir backup
fi

sourcedir=`pwd`
pushd /var/www/miq/vmdb

# Deploy Images
echo "Deploying Images"

# Backup the default branding if it hasn't been done
if [ ! -f productization/assets/images/layout/brand.svg ]; then
  mv productization/assets/images/layout/brand.svg ${sourcedir}/backup/brand.svg.orig
fi

# Deploy CBTS Brand in upper left corner
install -m 644 $sourcedir/brand.svg productization/assets/images/layout/brand.svg

# Deploy CBTS Header Banner
install -m 644 $sourcedir/VDCInternalBanner.jpg public/images/layout/VDCInternalBanner.jpg

# Patch the CSS
echo "Replacing CSS files"
for file in header.css.erb login.css.erb; do
  if [ ! -f productization/assets/stylesheets/${file}.orig ]; then
    mv productization/assets/stylesheets/${file} ${sourcedir}/backup/${file}.orig
  fi

  install -m 644 $sourcedir/${file} productization/assets/stylesheets/${file}
done

# Patch the UI Constants (to make the top border Orange by default)
echo "Patching UI Constants"
patch -p0 < $sourcedir/constants.diff

# Rebuild assets in Cloud Forms
echo "Rebuilding UI Assets"
rake evm:compile_assets

echo "Branding complete"
popd
