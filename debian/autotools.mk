# -*- mode: makefile; coding: utf-8 -*-
# Copyright © 2002,2003 Colin Walters <walters@debian.org>
# Description: A class to configure and build GNU autoconf+automake packages
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
# 02111-1307 USA.


ifndef _cdbs_bootstrap
_cdbs_scripts_path ?= /usr/lib/cdbs
_cdbs_rules_path ?= /usr/share/cdbs/1/rules
_cdbs_class_path ?= /usr/share/cdbs/1/class
endif

ifndef _cdbs_class_autotools
_cdbs_class_autotools := 1

include $(_cdbs_class_path)/autotools-files.mk$(_cdbs_makefile_suffix)

# Overriden from makefile-vars.mk.  We pass CFLAGS and friends to ./configure, so
# no need to pass them to make.
DEB_MAKE_INVOKE = $(DEB_MAKE_ENVVARS) make -C $(DEB_BUILDDIR)

common-configure-arch common-configure-indep:: common-configure-impl
common-configure-impl:: $(DEB_BUILDDIR)/config.status
$(DEB_BUILDDIR)/config.status:
	if test -n "$(DEB_AUTO_UPDATE_AUTOMAKE)" ; then \
		if test -d $(DEB_SRCDIR)/m4 ; then m4="-I m4" ; fi ; \
		if test -e $(DEB_SRCDIR)/aclocal.m4 ; then cd $(DEB_SRCDIR) && aclocal-$(DEB_AUTO_UPDATE_AUTOMAKE) $(m4) ; fi ; \
	fi
	if test -n "$(DEB_AUTO_UPDATE_AUTOCONF)" ; then \
		if test "$(DEB_AUTO_UPDATE_AUTOCONF)" = "2.50" ; then ac_suffix="" ; else ac_suffix="$(DEB_AUTO_UPDATE_AUTOCONF)" ; fi ; \
		if test -e $(DEB_SRCDIR)/configure.ac || test -e $(DEB_SRCDIR)/configure.in ; then cd $(DEB_SRCDIR) && autoconf$(ac_suffix) ; fi \
	fi
	if test -n "$(DEB_AUTO_UPDATE_AUTOMAKE)" ; then \
		if test -e $(DEB_SRCDIR)/Makefile.am ; then cd $(DEB_SRCDIR) && automake-$(DEB_AUTO_UPDATE_AUTOMAKE) ; fi ; \
	fi
	chmod a+x $(DEB_CONFIGURE_SCRIPT)
	$(DEB_CONFIGURE_INVOKE) $(cdbs_configure_flags) $(DEB_CONFIGURE_EXTRA_FLAGS) $(DEB_CONFIGURE_USER_FLAGS)

clean::
	if test -f $(DEB_BUILDDIR)/config.status && grep -i -q 'Generated.*by configure.' $(DEB_BUILDDIR)/config.status; then rm -f $(DEB_BUILDDIR)/config.status; fi
	if test -f $(DEB_BUILDDIR)/config.cache && grep -i -q 'shell.*script.*caches.*results.*configure' $(DEB_BUILDDIR)/config.cache; then rm -f $(DEB_BUILDDIR)/config.cache; fi

endif
