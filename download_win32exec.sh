#! /bin/sh --
# by pts@fazekas.hu at Thu Jun 25 11:14:10 CEST 2020
# TODO(pts): Add an equivalent which works for Win32.
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
chmod 755 dosmc.dir.win32exec-v1.7z.exe
./dosmc.dir.win32exec-v1.7z.exe -y
: "$0" OK.
