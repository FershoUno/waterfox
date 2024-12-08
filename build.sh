#!/bin/bash

##############################
# Download Waterfox compiled #
##############################

WATERFOX_BROWSER=$(curl -I https://cdn1.waterfox.net/waterfox/releases/latest/linux -s | grep -i -e "location:" -e "linux" | awk '{print $2}' | tr -d '\r')
wget -q --show-progress "$WATERFOX_BROWSER"

WATERFOX=$(ls waterfox-* | sed -E 's/([^-]+)-([0-9.]+)\..*/\1 \2/')
NAME=$(echo $WATERFOX | awk '{print $1}')
VERSION=$(echo $WATERFOX | awk '{print $2}')
ARCH="amd64"
WORK_DIR="$NAME-$VERSION-$ARCH"

mkdir -p $WORK_DIR/{DEBIAN,lib,usr/{bin,share/applications,icons/hicolor/scalable/apps}}
tar -xjf waterfox-*.tar.bz2 -C $WORK_DIR/lib/
ln -s ../../lib/waterfox/waterfox $WORK_DIR/usr/bin/waterfox


#################################
# Download icon SVG from github #
#################################

wget -q --show-progress https://raw.githubusercontent.com/BrowserWorks/website/refs/heads/main-ssg/public/images/waterfox-icon.svg -P $WORK_DIR/usr/share/icons/hicolor/scalable/apps/


##################
# DEBIAN/control #
##################

echo "Package: $NAME
Version: $VERSION
Section: web
Priority: optional
Architecture: $ARCH
Installed-Size: SIZE_TMP
Maintainer: FershoUno <fersh0un0@gmail.com>
Old-Maintainer: Alex Kontos
Homepage: https://www.waterfox.net/
Description: Waterfoxun navegador esteticamente agradable, enfocado en la velocidad y privacidad de los usuarios.
" > $WORK_DIR/DEBIAN/control

echo "#!/bin/bash
rm -rf /lib/waterfox
" > $WORK_DIR/DEBIAN/postrm
chmod 755 $WORK_DIR/DEBIAN/postrm

###################
# Create launcher #
###################

echo "[Desktop Entry]
Type=Application
Version=$VERSION
Name=$NAME
Keywords=Internet;
Exec=waterfox %u
Icon=waterfox-icon
Terminal=false
Categories=GTK;Network;WebBrowser;
" > $WORK_DIR/usr/share/applications/waterfox.desktop


##########################
# Calculate Package Size #
##########################

SIZE_WATERFOX=$(du -ks $WORK_DIR)
sed -i 's/SIZE_TMP/$SIZE_WATERFOX/g' $WORK_DIR/DEBIAN/control


dpkg-deb --build $WORK_DIR
