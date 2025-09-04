#! /usr/bin/env bash

brew uninstall hping
brew install tcl-tk
brew install libpcap
rm -rf /usr/local/bin/hping*
rm -rf /usr/local/sbin/hping*

export LDFLAGS="-L/usr/local/opt/tcl-tk/lib"
export CPPFLAGS="-I/usr/local/opt/tcl-tk/include"
export PKG_CONFIG_PATH="/usr/local/opt/tcl-tk/lib/pkgconfig"

# sudo csrutil authenticated-root disable
# csrutil disable
cd /tmp
rm -rf hping
mkdir hping
cd hping
git clone https://github.com/antirez/hping.git
cd hping
git reset --hard 3547c76
# /usr/local/opt/tcl-tk/bin/

sed -i -e 's/"\/usr\/bin\/" "\/usr\/local\/bin\/" "\/bin\/"/"\/usr\/bin\/" "\/usr\/local\/bin\/" "\/bin\/" "\/usr\/local\/opt\/tcl-tk\/bin\/" /g' configure

version=$(ls /usr/local/opt/tcl-tk/bin/ | grep tclsh | awk -F "tclsh" '{print $NF}' | awk NF)
sed -i -e 's/for TCLVER_TRY in/for TCLVER_TRY in "'${version}'"/g' configure
sed -i -e 's/\/usr\/include\/tcl\//\/usr\/local\/opt\/tcl-tk\/lib\/tcl\//g' configure

sed -i -e 's/\/usr\/sbin\//\/usr\/local\/bin\//g' Makefile.in
# sed -i -e 's/\/usr\/local\/man/\/usr\/share\/man/g' configure

./configure
make strip
sudo make install
cp -f hping3 /usr/local/sbin/
chmod 755 /usr/local/sbin/hping3
ln -s /usr/local/sbin/hping3 /usr/local/sbin/hping
ln -s /usr/local/sbin/hping3 /usr/local/sbin/hping2
