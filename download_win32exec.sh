#! /bin/sh --
# by pts@fazekas.hu at Thu Jun 25 11:14:10 CEST 2020
# This script runs on Linux i386 (because of /bin/sh and tiny7zx.
# TODO(pts): Port this script to Win32.
set -ex
cd "${0%/*}"
test -f dosmc.dir/dosmc.pl
if ! test -f dosmc.dir.win32exec-v1.7z.exe; then
  if type wget >/dev/null 2>&1; then  # `type -p' doesn't work with Bash as /bin/sh.
    wget -nv -O dosmc.dir.win32exec-v1.7z.exe.tmp https://github.com/pts/dosmc/releases/download/executables-v1/dosmc.dir.win32exec-v1.7z.exe
  else
    curl -sSLfo dosmc.dir.win32exec-v1.7z.exe.tmp https://github.com/pts/dosmc/releases/download/executables-v1/dosmc.dir.win32exec-v1.7z.exe
  fi
  mv dosmc.dir.win32exec-v1.7z.exe.tmp dosmc.dir.win32exec-v1.7z.exe
fi
if ! test -f tiny7zx; then
  if type wget >/dev/null 2>&1; then  # `type -p' doesn't work with Bash as /bin/sh.
    wget -nv -O tiny7zx.tmp https://github.com/pts/pts-tiny-7z-sfx/releases/download/v9.22%2Bpts6/tiny7zx
  else
    curl -sSLfo tiny7zx.tmp https://github.com/pts/pts-tiny-7z-sfx/releases/download/v9.22%2Bpts6/tiny7zx
  fi
  mv tiny7zx.tmp tiny7zx
fi
chmod 755 tiny7zx
./tiny7zx -y dosmc.dir.win32exec-v1.7z.exe
: "$0" OK.
