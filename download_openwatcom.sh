#! /bin/sh --
# by pts@fazekas.hu at Thu Jun 25 11:14:10 CEST 2020
set -ex
cd "${0%/*}"
if ! test -f open-watcom-2_0-c.zip; then
  wget -O open-watcom-2_0-c.zip.tmp https://github.com/open-watcom/open-watcom-v2/releases/download/Current-build/open-watcom-2_0-c-linux-x86
  mv open-watcom-2_0-c.zip.tmp open-watcom-2_0-c.zip
fi
rm -rf ow2bin binl
mkdir binl
unzip open-watcom-2_0-c.zip binl/wcc binl/wdis
chmod +x binl/wcc binl/wdis
mv binl ow2bin
: "$0" OK.
