#!/bin/bash

# pass 'DISTVER=xyz' to make command to pick a build repo (v2, v3, early).
# defaults to early
DISTVER="${DISTVER:-early}"

# Similar to genmeta, but this updates latest from the source
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

utime=$(jq -r .buildutime $DJSON)
buildver=$(jq -r .buildver $DJSON)
build=$(echo $buildver | cut -d- -f1)
rel=$(echo $buildver | cut -d- -f2)

buildint=$(echo $rel | sed -r 's/^0+//g')
if [ ! "$buildint" ]; then
  echo "Can't figure out buildint from $rel, aborting"
  exit
fi

#RELDEST=builds/$DISTVER/$build/$rel
RELDEST=builds/$build/$rel/$utime

ISODEST=$DEPOTISODEST/$RELDEST
#RSYNCDEST="pkg.sendfax.to:/usr/local/distro/webroot/builds/"
FILESIZE=$(stat -c'%s' $INCOMINGISO)

set -x

echo "Publishing $INCOMINGISO ($FILESIZE bytes) to $ISODEST..."
mkdir -p $ISODEST
cp $INCOMINGISO* $ISODEST
MARKER="/phonebocx/$RELDEST/$(basename $INCOMINGISO)"
#MARKER="/$RELDEST/$(basename $INCOMINGISO)"
echo $MARKER >$PUBLISHDEST

BASEURL=http://goldlinux.com
#BASEURL=$(jq -r .baseurl $DJSON)
ISOURL=$BASEURL$MARKER
#RSYNC=$(rsync -a $DEPOTISODEST/builds/$DISTVER $RSYNCDEST)
CL=$(curl -s -w '%header{content-length}' --head $ISOURL -o /dev/null)

if [ ! "$CL" ]; then
  echo "Something failed, could not get a Content-Length from $ISOURL, Panic."
  exit 9
fi
if [ "$CL" != "$FILESIZE" ]; then
  echo "Content length of '$CL' does not match filesize of '$FILESIZE'"
  echo "Is something caching $ISOURL or something?"
  exit 9
fi
echo "Confirmed that $ISOURL and $INCOMINGISO match in filesize. Should be good."
