#!/bin/sh
#
# $Id$
#
# Copyright (C) 2004, 2005 Guillem Jover <guillem@debian.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#

PKG=inetutils
export CVSROOT=":pserver:anonymous@cvs.sv.gnu.org:/sources/$PKG"

set -e

SRCDIR="$PKG-snapshot"

case "$1" in
  snapshot)
    echo "-> getting new snapshot."
#    cvs login
    cvs -z3 co -d $SRCDIR $PKG
    ;;
  update)
    echo "-> updating snapshot."
    cvs -z3 up -dP $SRCDIR
    ;;
esac

if ! [ -e $SRCDIR/libinetutils ]
then
  echo "error: no $PKG source dir available."
  exit 1
fi

echo "-> creating new directory tree."
VERSION=$(grep ^AC_INIT $SRCDIR/configure.ac | \
  sed -e 's/.*, *\[\([^,]*\)\] *,.*/\1/')
SNAPSHOTVERSION="$VERSION+$(date +%Y%m%d)"
TARBALLDIR="$PKG-$SNAPSHOTVERSION"
cp -al $SRCDIR $TARBALLDIR

echo "-> cleaning snapshot."
# Clean non-free stuff
:

# Clean cvs stuff
find $TARBALLDIR -name 'CVS' -o -name '.cvsignore' | xargs rm -rf

echo "-> creating new tarball."
tar czf ${PKG}_$SNAPSHOTVERSION.orig.tar.gz $TARBALLDIR

echo "-> cleaning directory tree."
rm -rf $TARBALLDIR

