#+======================================================================
# $HeadURL: https://svnpub.iter.org/codac/iter/codac/dev/units/m-css-iter/trunk/src/main/tycho/org.csstudio.iter/products/org.csstudio.iter.css.product/demo/m-TEST/src/main/epics/myCSTMApp/Makefile $
# $Id: Makefile 97320 2019-01-29 17:17:28Z utzeln $
#
# Project       : CODAC Core System
#
# Description   : Makefile
#
# Author(s)     : Cosylab
#
# Copyright (c) : 2010-2019 ITER Organization,
#                 CS 90 046
#                 13067 St. Paul-lez-Durance Cedex
#                 France
#
# This file is part of ITER CODAC software.
# For the terms and conditions of redistribution or use of this software
# refer to the file ITER-LICENSE.TXT located in the top level directory
# of the distribution package.
#
#-======================================================================
TOP = ..
include $(TOP)/configure/CONFIG
DIRS := $(DIRS) $(filter-out $(DIRS), $(wildcard *src*))
DIRS := $(DIRS) $(filter-out $(DIRS), $(wildcard *Src*))
DIRS := $(DIRS) $(filter-out $(DIRS), $(wildcard *db*))
DIRS := $(DIRS) $(filter-out $(DIRS), $(wildcard *Db*))
include $(TOP)/configure/RULES_DIRS

