#
# Dockerfile to build adtools cross-compiler
#
# The binaries will ultimately be found in /opt/adtools
#
# The idea with this image is to produce a bare minimum base from
# which to create more specific builders. The cross-compiler
# executes but no other tools are available.
#

FROM debian:buster

LABEL maintainer="Steven Solie <steven@solie.ca>"

#
# This is where the build will take place and is removed when finished.
#
WORKDIR /work

#
# Perform all the steps in a single RUN to avoid creating file system layers.
#
# Note libmpc3 and libfl2 are not purged because they are needed to
# run the cross-compiler.
#
RUN apt-get update && apt-get upgrade --yes && \
  apt-get install -y \
    git \
    python2.7 \
    make \
    g++-8 \
    libmpc3 \
    libfl2 \
    libgmp-dev \
    libmpc-dev \
    libtool \
    flex \
    texinfo \
    wget \
    lhasa \
  && \
  ln -s /usr/bin/python2.7 /usr/bin/python && \
  ln -s /usr/bin/g++-8 /usr/bin/g++ \
  && \
  git config --global user.email me@github.com && \
  git clone https://github.com/sba1/adtools . && \
  git submodule init && \
  git submodule update && \
  gild/bin/gild clone && \
  gild/bin/gild checkout binutils 2.23.2 && \
  gild/bin/gild checkout gcc 8 \
  && \
  make -C native-build gcc-cross CROSS_PREFIX=/opt/adtools \
  && \
  rm -rf /work/* && \
  rm /usr/bin/python && \
  rm /usr/bin/gcc && \
  rm /usr/bin/g++ \
  && \
  apt-get --assume-yes purge \
    git \
    python2.7 \
    make \
    g++-8 \
    libgmp-dev \
    libmpc-dev \
    libtool \
    flex \
    texinfo \
    wget \
    lhasa \
  && \
  apt-get --assume-yes autoremove && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

