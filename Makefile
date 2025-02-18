###############################################################################
#                                                                             #
# Makefile for libplot                                                        #
#                                                                             #
#  Developed by :                                                             #
#      AquaticEcoDynamics (AED) Group                                         #
#      School of Agriculture and Environment                                  #
#      The University of Western Australia                                    #
#                                                                             #
#  Copyright 2013 - 2025 -  The University of Western Australia               #
#                                                                             #
#   libplot is free software: you can redistribute it and/or modify           #
#   it under the terms of the GNU General Public License as published by      #
#   the Free Software Foundation, either version 3 of the License, or         #
#   (at your option) any later version.                                       #
#                                                                             #
#   libplot is distributed in the hope that it will be useful,                #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of            #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             #
#   GNU General Public License for more details.                              #
#                                                                             #
#   You should have received a copy of the GNU General Public License         #
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.     #
#                                                                             #
###############################################################################

ifeq ($(shell uname),Linux)
  OSTYPE=$(shell uname -s)
else ifeq ($(shell uname),Darwin)
  OSTYPE=$(shell uname -s)
else ifeq ($(shell uname),FreeBSD)
  OSTYPE=$(shell uname -s)
else
  OSTYPE=$(shell uname -o)
endif

ifeq ($(MDEBUG),true)
  DEBUG=true
endif

srcdir=src
incdir=include
INCLUDES=-I${incdir} -I.
LIBS=-lgd -lpng -ljpeg -lm
CFLAGS=-O3

ifeq ($(WITH_XPLOTS),)
  WITH_XPLOTS=true
endif

ifeq ($(OSTYPE),Darwin)
  uibasic=macbasic
  srcext=m
  CC=clang
else ifeq ($(OSTYPE),Msys)
  uibasic=winbasic
  srcext=c
  CC=gcc
else
  uibasic=xbasic
  srcext=c
endif
ifeq ($(MDEBUG),true)
  CFLAGS+=-fsanitize=address
endif
ifeq ($(DEBUG),true)
  CFLAGS+=-g
endif

ifeq ($(SINGLE),true)
  objdir=obj_s
  TARGET=lib/libplot_s.a
else
  objdir=obj
  TARGET=lib/libplot.a
endif

OBJS=${objdir}/${uibasic}.o \
     ${objdir}/colours.o \
     ${objdir}/plotter.o

ifeq ($(OSTYPE),Linux)
  CFLAGS+=-Wno-format-truncation
endif

ifeq ($(WITH_XPLOTS),true)
  CFLAGS+=-DXPLOTS
endif

ifeq ($(OSTYPE),Darwin)
  INCLUDES+=-I/opt/local/include -I/usr/local/include -I/opt/homebrew/include
  LIBS+=-framework Cocoa -L/opt/local/lib -L/usr/local/lib -L/opt/homebrew/lib
else ifneq ($(OSTYPE),Msys)
  INCLUDES+=-I/usr/local/include
  LIBS+=-lX11
else
  INCLUDES+=-I../ancillary/windows/include -I../win
  LIBS+=-L../ancillary/windows/include -I../win
endif

# if we are building static lib...
CFLAGS+=-fPIE

all: ${TARGET}

${TARGET}: ${objdir} ${OBJS} lib
	ar rv $@ ${OBJS}
	ranlib $@

clean: ${objdir}
	@touch ${objdir}/1.o
	@/bin/rm ${objdir}/*.o
	@/bin/rmdir ${objdir}
	@touch tstmap tstfont
	@/bin/rm tstmap tstfont

distclean: clean
	@touch mod mod_s lib
	@/bin/rm -rf lib mod mod_s

lib:
	@mkdir lib

${objdir}:
	@mkdir ${objdir}

${objdir}/%.o: ${srcdir}/%.c ${incdir}/%.h
	$(CC) -Wall $(CFLAGS) $(INCLUDES) -g -c $< -o $@

${objdir}/${uibasic}.o: ${srcdir}/${uibasic}.${srcext}
	$(CC) -Wall $(CFLAGS) $(INCLUDES) -g -c $< -o $@

tstmap: tests/tstmap.c ${TARGET}
	$(CC) -DTRUE_COLOUR=1 $(CFLAGS) $(INCLUDES) tests/tstmap.c ${TARGET} $(LIBS) -o $@

tstfont: tests/tstfont.c ${TARGET}
	$(CC) -DTRUE_COLOUR=1 $(CFLAGS) $(INCLUDES) tests/tstfont.c ${TARGET} $(LIBS) -o $@

