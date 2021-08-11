#! /bin/bash

################################################################################
# Build
################################################################################

# Set up shell
if [ "$(echo ${VERBOSE} | tr '[:upper:]' '[:lower:]')" = 'yes' ]; then
    set -x                      # Output commands
fi
set -e                          # Abort on errors



# Set locations
THORN=ssht
NAME=ssht-1.5.0
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
cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} ..

echo "ssht: Building..."
${MAKE}

echo "ssht: Installing..."
${MAKE} install
popd

echo "ssht: Cleaning up..."
rm -rf ${BUILD_DIR}

date > ${DONE_FILE}
echo "ssht: Done."
