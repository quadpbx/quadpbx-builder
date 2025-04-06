#!/bin/bash

if [ ! -d "$ISOBUILDROOT" ]; then
  echo "ISOBUILDROOT '$ISOBUILDROOT' is not a directory?"
  exit 9
fi

# I'm lazy, saves typing
R=$ISOBUILDROOT

BI=$R/binary/distro/buildinfo.json
DJSON=$R/binary/distro/distrovars.json
if [ ! -e "$DJSON" ]; then
  echo "Cannot read $DJSON"
  exit 9
fi

DESTFILE=$1
if [ ! "$DESTFILE" ]; then
  echo "No destination of the meta output provided"
  exit 9
fi

utime=$(jq -r .buildutime $DJSON)
buildver=$(jq -r .buildver $DJSON)
build=$(echo $buildver | cut -d- -f1)
rel=$(echo $buildver | cut -d- -f2)

buildint=$(echo $rel | sed -r 's/^0+//g')
if [ ! "$buildint" ]; then
  echo "Can't figure out buildint from $rel, aborting"
  exit
fi

if [ ! -e "$INCOMINGISOHASH" ]; then
  echo "Can't find INCOMINGISOHASH '$INCOMINGISOHASH'"
  exit 9
fi

sha=$(cat $INCOMINGISOHASH)

cat >$DESTFILE <<EOF
[general]
version=1
utime=$utime
fullbuild=$buildver
build=$build
rel=$rel
sha256sum=$sha
sha256file=$(basename $INCOMINGISOHASH)
[squashfs]
EOF

grep squashfs$ $R/binary/sha256sum.txt | sed -E -e 's/^([^ ]+)\s+\.\/live\/(.+)$/\2=\1/' -e 's/packages\///' >>$DESTFILE

echo '[pkgmeta]' >>$DESTFILE
for m in $R/binary/live/packages/*squashfs.meta; do
  if [ ! -e "$m" ]; then
    continue
  fi
  echo "$(basename $m | sed 's/.squashfs.meta//')=$(base64 -w0 $m)" >>$DESTFILE
done

echo "Created $DESTFILE from $R"
