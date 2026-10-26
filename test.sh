#!/usr/bin/env bash
cd "$(dirname "$0")"
source ./script/setup.sh

./build-debug.sh -Xswiftc -warnings-as-errors
./swift-test.sh

./.debug/aerostage-wm -h > /dev/null
./.debug/aerostage-wm --help > /dev/null
./.debug/aerostage-wm -v | grep -q "0.0.0-SNAPSHOT SNAPSHOT"
./.debug/aerostage-wm --version | grep -q "0.0.0-SNAPSHOT SNAPSHOT"

./lint.sh
./generate.sh
./script/check-uncommitted-files.sh

echo
echo "✅ All tests have passed successfully"
