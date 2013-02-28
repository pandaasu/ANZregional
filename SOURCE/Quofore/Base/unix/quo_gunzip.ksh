#!/usr/bin/ksh
#
#   Script  : quo_gunzip.ksh
#   Author  : Mal Chambeyron
#
#   Description
#   -----------------------------------------------------------------------------
#   Wrapper for /usr/bin/gunzip .. as fallback when LICS Java ZLIB Fails
#
#   YYYY-MM-DD   Author                 Description
#   ----------   --------------------   -----------------------------------------
#   2013-02-25   Mal Chambeyron         Created
#
if [[ -z ${2} ]]
then
  echo "Usage ${0} {Source File - Compressed} {Destination File - Uncompressed}"
  exit 1
fi

/usr/bin/gunzip -c ${1} > ${2}

