# -*- mode: makefile; coding: utf-8 -*-
# Copyright ?? 2002,2003 Colin Walters <walters@debian.org>
# Description: A simple patch system which uses separate files in debian/patches
# 
# Modified by Julian Gilbey <jdg@debian.org> to apply patches to DEB_SRCDIR
# instead of DEB_BUILDDIR
# 
#  Patch names must end in .patch, currently.
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

ifndef _cdbs_rules_patchsys
_cdbs_rules_patchsys := 1

include $(_cdbs_rules_path)/buildcore.mk$(_cdbs_makefile_suffix)

ifeq ($(_cdbs_included_patchsys),)
_cdbs_included_patchsys := 1

_cdbs_patch_system_apply_rule := apply-patches
_cdbs_patch_system_unapply_rule := reverse-patches

DEB_PATCHDIRS = debian/patches
DEB_PATCHES = $(foreach dir,$(DEB_PATCHDIRS),$(shell echo $(wildcard $(dir)/*.patch) $(wildcard $(dir)/*.diff)))

post-patches:: apply-patches

clean:: reverse-patches
	rm -f debian/stamp-patch*
	rm -f debian/patches/*.log

# The patch subsystem 
apply-patches: pre-build debian/stamp-patched
debian/stamp-patched: $(DEB_PATCHES)
debian/stamp-patched reverse-patches:
	@echo "patches: $(DEB_PATCHES)"
	@set -e ; reverse=""; patches="$(DEB_PATCHES)"; \
	  if [ "$@" = "reverse-patches" ]; then \
	    reverse="-R"; \
	    for patch in $$patches; do reversepatches="$$patch $$reversepatches"; done; \
	    patches="$$reversepatches"; \
	  fi; \
	  for patch in $$patches; do \
	  level=$(head $$patch | egrep '^#DPATCHLEVEL=' | cut -f 2 -d '='); \
	  reverse=""; \
	  if [ "$@" = "reverse-patches" ]; then reverse="-R"; fi; \
	  success=""; \
	  if [ -z "$$level" ]; then \
	    echo -n "Trying "; if test -n "$$reverse"; then echo -n "reversed "; fi; echo -n "patch $$patch at level "; \
	    for level in 0 1 2; do \
	      if test -z "$$success"; then \
	        echo -n "$$level..."; \
	        if cat $$patch | patch -d $(DEB_SRCDIR) $$reverse -E --dry-run -p$$level 1>$$patch.level-$$level.log 2>&1; then \
	          if cat $$patch | patch -d $(DEB_SRCDIR) $$reverse -E --no-backup-if-mismatch -V never -p$$level 1>$$patch.level-$$level.log 2>&1; then \
	            success=yes; \
	            touch debian/stamp-patch-$$(basename $$patch); \
	            echo "success."; \
                  fi; \
	        fi; \
	      fi; \
            done; \
	    if test -z "$$success"; then \
	      if test -z "$$reverse"; then \
	        echo "failure."; \
	        exit 1; \
	       else \
	         echo "failure (ignored)."; \
               fi \
	    fi; \
	  else \
	    echo -n "Trying patch $$patch at level $$level..."; \
	    if cat $$patch | patch -d $(DEB_SRCDIR) $$reverse -E --no-backup-if-mismatch -V never -p$$level 1>$$patch.log 2>&1; then \
              touch debian/stamp-patch-$$(basename $$patch); \
	      echo "success."; \
	    else \
	      echo "failure:"; \
	      cat $$patch.log; \
	      if test -z "$$reverse"; then exit 1; fi; \
            fi; \
	  fi; \
	done
	if [ "$@" = "debian/stamp-patched" ]; then touch debian/stamp-patched; fi

endif

endif
