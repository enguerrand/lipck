#!/bin/bash

#This file is part of lipck - the "linux install party customization kit".
#
# Copyright (C) 2014 trilader, Christopher Spinrath
#
# lipck is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# lipck is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with lipck.  If not, see <http://www.gnu.org/licenses/>.


set -e

DIR=$(pwd)

if [ ! -e "$DIR/lip32" -o ! -e "$DIR/lip64" ]; then
	echo "Working directories not existing. Please run unsquash.sh before this"
	exit 1
fi

if [ -e "$DIR/lipcommon" ]; then
	echo "lipcommon dir exists. Please remove it before running this"
	exit 1
fi

echo -n "Creating 32-bit checksums... "
pushd "$DIR/lip32" > /dev/null
find . -type f -print0 | sort -z | xargs -0 md5sum > "$DIR/32.md5"
popd > /dev/null
echo "done"

echo -n "Creating 64-bit checksums... "
pushd "$DIR/lip64" > /dev/null
find . -type f -print0 | sort -z | xargs -0 md5sum > "$DIR/64.md5"
popd > /dev/null
echo "done"

mkdir -p "$DIR/lipcommon"

echo -n "Diffing checksums... "
diff --old-line-format="" --new-line-format="" --unchanged-line-format="%L" "$DIR/32.md5" "$DIR/64.md5" > "$DIR/both.md5" || true
echo "done"

echo -n "Deduplicating... "
cut -d" " -f3- "$DIR/both.md5" | tr \\n \\0 | (cd "$DIR/lip64"; xargs -0 cp -v --parents -pt "$DIR/lipcommon/" )
cut -d" " -f3- "$DIR/both.md5" | tr \\n \\0 | (cd "$DIR/lip32"; xargs -0 rm )
cut -d" " -f3- "$DIR/both.md5" | tr \\n \\0 | (cd "$DIR/lip64"; xargs -0 rm )
echo "done"

echo "Ok. Now run squash.sh"

exit 0;
