#! /bin/sh --
# by pts@fazekas.hu at Thu Jun 25 11:14:10 CEST 2020
set -ex
cd "${0%/*}"
test -f dosmc.dir/dosmc.pl
if ! test -f dosmc.dir.linuxi386exec-v1.sfx.7z; then
  if type wget >/dev/null 2>&1; then  # `type -p' doesn't work with Bash as /bin/sh.
    wget -nv -O dosmc.dir.linuxi386exec-v1.sfx.7z.tmp https://github.com/pts/dosmc/releases/download/executables-v1/dosmc.dir.linuxi386exec-v1.sfx.7z
  else
    curl -sSLfo dosmc.dir.linuxi386exec-v1.sfx.7z.tmp https://github.com/pts/dosmc/releases/download/executables-v1/dosmc.dir.linuxi386exec-v1.sfx.7z
  fi
  mv dosmc.dir.linuxi386exec-v1.sfx.7z.tmp dosmc.dir.linuxi386exec-v1.sfx.7z
fi
chmod 755 dosmc.dir.linuxi386exec-v1.sfx.7z
./dosmc.dir.linuxi386exec-v1.sfx.7z -y
: "$0" OK.
