#!/bin/bash -e
# OpenFOAM CFD build script
. /etc/profile.d/modules.sh

module add ci
# FOAM Dependencies as described on http://openfoam.org/download/source.php
# cmake zlib1g-dev libboost-system-dev libboost-thread-dev libopenmpi-dev openmpi-bin gnuplot libreadline-dev libncurses-dev libxt-dev
# Scotch and cgal are option ?
module add readline
module add zlib
module add  boost/1.59.0-gcc-5.1.0-mpi-1.8.8
module add gcc/${GCC_VERSION}
module add openmpi/1.8.8-gcc-${GCC_VERSION}
FOAM_SOURCE_FILE=${NAME}-${VERSION}.tgz
FOAM_THIRD_PARTY_SOURCE_FILE=ThirdParty-${VERSION}.tgz
echo "Checking FOAM"

if [ ! -e ${SRC_DIR}/${FOAM_SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${FOAM_SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${FOAM_SOURCE_FILE}.lock
  echo "seems like this is the first build - let's get the source"
  mkdir -p ${SRC_DIR}
  wget http://downloads.sourceforge.net/project/foam/foam/
${VERSION}/${FOAM_SOURCE_FILE} -O ${SRC_DIR}/${FOAM_SOURCE_FILE}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${FOAM_SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${FOAM_SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${FOAM_SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${FOAM_SOURCE_FILE}
fi

echo "Checking ThirdParty"

if [ ! -e ${SRC_DIR}/${THIRD_PARTY_SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${THIRD_PARTY_SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${THIRD_PARTY_SOURCE_FILE}.lock
  echo "seems like this is the first build - let's get the source"
  mkdir -p ${SRC_DIR}
  wget http://downloads.sourceforge.net/project/foam/
/${THIRD_PARTY_SOURCE_FILE} -O ${SRC_DIR}/${THIRD_PARTY_SOURCE_FILE}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${THIRD_PARTY_SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${THIRD_PARTY_SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${THIRD_PARTY_SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${THIRD_PARTY_SOURCE_FILE}
fi

echo "Unpacking"

tar xvfz ${SRC_DIR}/${FOAM_SOURCE_FILE} -C ${WORKSPACE}
tar xvfz ${SRC_DIR}/${THIRD_PARTY_SOURCE_FILE} -C ${WORKSPACE}

export WM_NCOMPPROCS=2
export WM_COLOURS="black blue green cyan red magenta yellow"

# need to edit etc/bashrc
mkdir -p /home/becker/SAGrid-2.0/OpenFOAM-deploy//OpenFOAM-3.0.1/platforms/linux64GccDPInt64OptSYSTEMOPENMPI/src/Pstream/mpi/using
