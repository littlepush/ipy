#! /bin/sh

sudo rm -rf /tmp/PY*
cd PYCore
sudo ./xcode.build
cd ../
cd PYData
sudo ./xcode.build
cd ../
cd PYUIKit
sudo ./xcode.build
cd ../
