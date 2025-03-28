#! /bin/bash

################################################################################
# Build
################################################################################

# Set up shell
if [ "$(echo ${VERBOSE} | tr '[:upper:]' '[:lower:]')" = 'yes' ]; then
    set -x                      # Output commands
fi
set -e                          # Abort on errors


    
# Define some environment variables
export CC=${EXTERNAL_CC:-${CC}}
export CXX=${EXTERNAL_CXX:-${CXX}}
export F90=${EXTERNAL_F90:-${F90}}
export LD=${EXTERNAL_LD:-${LD}}
export CFLAGS=${EXTERNAL_CFLAGS:-${CFLAGS}}
export CXXFLAGS=${EXTERNAL_CXXFLAGS:-${CXXFLAGS}}
export F90FLAGS=${EXTERNAL_F90FLAGS:-${F90FLAGS}}
export LDFLAGS=${EXTERNAL_LDFLAGS:-${LDFLAGS}}



# Set locations
THORN=ssht
NAME=ssht-1.5.1
SRCDIR="$(dirname $0)"
BUILD_DIR=${SCRATCH_BUILD}/build/${THORN}
if [ -z "${SSHT_INSTALL_DIR}" ]; then
    INSTALL_DIR=${SCRATCH_BUILD}/external/${THORN}
else
    echo "BEGIN MESSAGE"
    echo "Installing ssht into ${SSHT_INSTALL_DIR}"
    echo "END MESSAGE"
    INSTALL_DIR=${SSHT_INSTALL_DIR}
fi
DONE_FILE=${SCRATCH_BUILD}/done/${THORN}
SSHT_DIR=${INSTALL_DIR}

echo "ssht: Preparing directory structure..."
cd ${SCRATCH_BUILD}
mkdir build external done 2> /dev/null || true
rm -rf ${BUILD_DIR} ${INSTALL_DIR}
mkdir ${BUILD_DIR} ${INSTALL_DIR}

# Build core library
echo "ssht: Unpacking archive..."
pushd ${BUILD_DIR}
${TAR?} xf ${SRCDIR}/../dist/${NAME}.tar

echo "ssht: Configuring..."
cd ${NAME}

unset LIBS

mkdir build
cd build
# cannot be passed as CMake option unfortunately
# not perfect since CMake still queries pkg-config but setting
# FFTW3_INCLUDE_DIR and FFTW3_LIBRARIES triggers abug in FindFFTW3.cmake where
# it returns() too early before all targets are set
# need to strip trailing spaces since they confuse CMake, and CMake needs ";"
# to separate paths
export FFTW3_LIBRARY_DIR="$(echo ${FFTW3_LIB_DIRS} | sed 's/ *$//;s/^ *//;s/ /;/g')"
export FFTW3_INCLUDE_DIR="$(echo ${FFTW3_INC_DIRS} | sed 's/ *$//;s/^ *//;s/ /;/g')"

${CMAKE_DIR:+${CMAKE_DIR}/bin/}cmake -DBUILD_TESTING:BOOL=OFF -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DFFTW3_FIND_COMPONENTS=DOUBLE_SERIAL ..

echo "ssht: Building..."
${MAKE}

echo "ssht: Installing..."
${MAKE} install
popd

echo "ssht: Cleaning up..."
rm -rf ${BUILD_DIR}

date > ${DONE_FILE}
echo "ssht: Done."
