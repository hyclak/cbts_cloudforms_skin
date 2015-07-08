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

if [ ! -f ${sourcedir}/backup/favicon.ico.orig ]; then
  mv productization/assets/images/favicon.ico ${sourcedir}/backup/favicon.ico.orig
fi

# Deploy CBTS Brand in upper left corner
install -m 644 ${sourcedir}/brand.svg productization/assets/images/brand.svg

# Deploy the CBTS favicon
install -m 644 ${sourcedir}/cbts-logo.ico productization/assets/images/favicon.ico

# Deploy the custom logo (blank image to remove Red Hat branding from upper right of login screen)  
install -m 644 ${sourcedir}/custom_logo.png public/upload/custom_logo.png

# Deploy the login background
install -m 644 ${sourcedir}/login-screen-background.png public/upload/custom_login_logo.png

# Deploy CBTS Header Banner
install -m 644 $sourcedir/internal-banner.jpg public/upload/internal-banner.jpg

# Enable Custom Logos
echo "Enabling Custom Logos"

# Turn Custom Logo and Background on
script/rails runner ${sourcedir}/enable_logos.rb

# Adjust Visual Elements
echo "Adjusting Visual Elements"

# Darken the login bar backround (change 0.2 to 0.8 transparency)
sed -i 's/\(\@login-container-bg-color-rgba:.*,\) 0.2);\(.*\)/\1 0.8);\2/' productization/assets/stylesheets/main.less

# Change the color of the top 3px bar from Red Hat Red to CBTS Orange
sed -i 's/\(\@navbar-pf-border-color:.*\) #c00;\(.*\)/\1 #e48d25;\2/' productization/assets/stylesheets/main.less

# Change the color of the navbar background to black with the internal banner image
sed -i 's/\(@navbar-pf-bg-color:.*\) #393F45;\(.*\)/\1 #000000;\2/' productization/assets/stylesheets/main.less

# Rebuild assets in Cloud Forms
echo "Rebuilding UI Assets"
rake evm:compile_assets

echo "Branding complete"
popd
