###############################################################################
#                                                                             #
# Makefile for libplot                                                        #
#                                                                             #
#  Developed by :                                                             #
#      AquaticEcoDynamics (AED) Group                                         #
#      School of Agriculture and Environment                                  #
#      The University of Western Australia                                    #
#                                                                             #
#  Copyright 2013 - 2022 -  The University of Western Australia               #
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
  INCLUDES+=-I../win-3rd-party/x64-Release/include -I../win
else
  uibasic=xbasic
  srcext=c
endif

ifeq ($(SINGLE),true)
  objdir=obj_s
  TARGET=lib/libplot_s.a
else
  objdir=obj
  TARGET=lib/libplot.a
endif

SRCS=${srcdir}/${uibasic}.${srcext} \
     ${srcdir}/colours.c \
     ${srcdir}/plotter.c

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
  INCLUDES+=-I/opt/local/include
  LIBS+=-framework Cocoa -L/opt/local/lib
else
  INCLUDES+=-I/usr/local/include
  LIBS+=-lX11
endif

ifeq ($(SINGLE),true)
  CFLAGS += -DSINGLE=1
endif

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
	$(CC) -Wall -fPIC $(CFLAGS) $(INCLUDES) -g -c $< -o $@

${objdir}/${uibasic}.o: ${srcdir}/${uibasic}.${srcext}
	$(CC) -Wall -fPIC $(CFLAGS) $(INCLUDES) -g -c $< -o $@

tstmap: tests/tstmap.c ${TARGET}
	$(CC) -DTRUE_COLOUR=1 $(CFLAGS) $(INCLUDES) tests/tstmap.c ${TARGET} $(LIBS) -o $@

tstfont: tests/tstfont.c ${TARGET}
	$(CC) -DTRUE_COLOUR=1 $(CFLAGS) $(INCLUDES) tests/tstfont.c ${TARGET} $(LIBS) -o $@

