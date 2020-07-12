#! /bin/sh --
# by pts@fazekas.hu at Thu Jun 25 11:14:10 CEST 2020
set -ex
cd "${0%/*}"
test -f dosmc.dir/dosmc.pl
if ! test -f open-watcom-2_0-c.zip; then
  wget -O open-watcom-2_0-c.zip.tmp https://github.com/open-watcom/open-watcom-v2/releases/download/Current-build/open-watcom-2_0-c-linux-x86
  mv open-watcom-2_0-c.zip.tmp open-watcom-2_0-c.zip
fi
rm -rf binl
mkdir -p binl dosmc.dir
# wdis is optional, used by `dosmc -cw'.
F='binl/wcc binl/wdis binl/wlink binl/wmake binl/dmpobj binl/owcc binl/wasm binl/wcl binl/wtouch'
unzip open-watcom-2_0-c.zip $F
chmod 755 $F
cp -a $F dosmc.dir/
: "$0" OK.
