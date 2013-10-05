#! /bin/sh

sudo rm -rf /tmp/PY*
cd PYCore
./xcode.build
cd ../
cd PYData
./xcode.build
cd ../
cd PYUIKit
./xcode.build
cd ../
