#! /bin/bash

################################################################################
# Prepare
################################################################################

# Set up shell
if [ "$(echo ${VERBOSE} | tr '[:upper:]' '[:lower:]')" = 'yes' ]; then
    set -x                      # Output commands
fi
set -e                          # Abort on errors

. $CCTK_HOME/lib/make/bash_utils.sh

# Take care of requests to build the library in any case
SSHT_DIR_INPUT=$SSHT_DIR
if [ "$(echo "${SSHT_DIR}" | tr '[a-z]' '[A-Z]')" = 'BUILD' ]; then
    SSHT_BUILD=1
    SSHT_DIR=
else
    SSHT_BUILD=
fi

# default value for FORTRAN support
if [ -z "$SSHT_ENABLE_FORTRAN" ] ; then
    SSHT_ENABLE_FORTRAN="OFF"
fi

################################################################################
# Decide which libraries to link with
################################################################################

# Set up names of the libraries based on configuration variables. Also
# assign default values to variables.
# Try to find the library if build isn't explicitly requested
if [ -z "${SSHT_BUILD}" -a -z "${SSHT_INC_DIRS}" -a -z "${SSHT_LIB_DIRS}" -a -z "${SSHT_LIBS}" ]; then
    find_lib SSHT ssht 1 1.0 "ssht" "ssht.H" "$SSHT_DIR"
fi

THORN=ssht

# configure library if build was requested or is needed (no usable
# library found)
if [ -n "$SSHT_BUILD" -o -z "${SSHT_DIR}" ]; then
    echo "BEGIN MESSAGE"
    echo "Using bundled ssht..."
    echo "END MESSAGE"
    SSHT_BUILD=1

    check_tools "tar patch"
    
    # Set locations
    BUILD_DIR=${SCRATCH_BUILD}/build/${THORN}
    if [ -z "${SSHT_INSTALL_DIR}" ]; then
        INSTALL_DIR=${SCRATCH_BUILD}/external/${THORN}
    else
        echo "BEGIN MESSAGE"
        echo "Installing ssht into ${SSHT_INSTALL_DIR}"
        echo "END MESSAGE"
        INSTALL_DIR=${SSHT_INSTALL_DIR}
    fi
    SSHT_DIR=${INSTALL_DIR}
    # Fortran modules may be located in the lib directory
    SSHT_INC_DIRS="${SSHT_DIR}/include ${SSHT_DIR}/lib"
    SSHT_LIB_DIRS="${SSHT_DIR}/lib"
    SSHT_LIBS="ssht"
else
    DONE_FILE=${SCRATCH_BUILD}/done/${THORN}
    if [ ! -e ${DONE_FILE} ]; then
        mkdir ${SCRATCH_BUILD}/done 2> /dev/null || true
        date > ${DONE_FILE}
    fi
fi

if [ -n "$SSHT_DIR" ]; then
    : ${SSHT_RAW_LIB_DIRS:="$SSHT_LIB_DIRS"}
    # Fortran modules may be located in the lib directory
    SSHT_INC_DIRS="$SSHT_RAW_LIB_DIRS $SSHT_INC_DIRS"
    # We need the un-scrubbed inc dirs to look for a header file below.
    : ${SSHT_RAW_INC_DIRS:="$SSHT_INC_DIRS"}
else
    echo 'BEGIN ERROR'
    echo 'ERROR in ssht configuration: Could neither find nor build library.'
    echo 'END ERROR'
    exit 1
fi

################################################################################
# Check for additional libraries
################################################################################


################################################################################
# Configure Cactus
################################################################################

# Pass configuration options to build script
echo "BEGIN MAKE_DEFINITION"
echo "SSHT_BUILD          = ${SSHT_BUILD}"
echo "SSHT_ENABLE_FORTRAN = ${SSHT_ENABLE_FORTRAN}"
echo "LIBSZ_DIR           = ${LIBSZ_DIR}"
echo "LIBZ_DIR            = ${LIBZ_DIR}"
echo "SSHT_INSTALL_DIR    = ${SSHT_INSTALL_DIR}"
echo "END MAKE_DEFINITION"

# Pass options to Cactus
echo "BEGIN MAKE_DEFINITION"
echo "SSHT_DIR            = ${SSHT_DIR}"
echo "SSHT_ENABLE_FORTRAN = ${SSHT_ENABLE_FORTRAN}"
echo "SSHT_INC_DIRS       = ${SSHT_INC_DIRS} ${ZLIB_INC_DIRS}"
echo "SSHT_LIB_DIRS       = ${SSHT_LIB_DIRS} ${ZLIB_LIB_DIRS}"
echo "SSHT_LIBS           = ${SSHT_LIBS}"
echo "END MAKE_DEFINITION"

echo 'INCLUDE_DIRECTORY $(SSHT_INC_DIRS)'
echo 'LIBRARY_DIRECTORY $(SSHT_LIB_DIRS)'
echo 'LIBRARY           $(SSHT_LIBS)'
