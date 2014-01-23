#! /bin/sh

for arg in $@; do
    key=$(echo $arg | cut -d = -f 1)
    if [ $? -ne 0 ]; then
        echo "Wrong Command."
        usage
        exit 1
    fi
    value=$(echo $arg | cut -d = -f 2)
    case $key in
    "CONFIG")
        Configuration=$value
        ;;
    "VERSION")
        FVersion=$value
        ;;
    "ACTION")
        Action=$value
        ;;
    *)
        echo "Unknow command $key."
        usage
        exit 1
        ;;
    esac
done

source config.hd

if [ "${Configuration}" == "" ]; then
    Configuration="Release"
fi

if [ "${FVersion}" == "" ]; then
    FVersion=$(CompileVersion)
fi

if [ "${Action}" == "" ]; then
    Action="Build"
fi

if [ "${Action}" == "Build" ]; then
    sudo rm -rf /tmp/PY*
    cd PYCore
    sudo ./xcode.build VERSION=${FVersion} CONFIG=${Configuration}
    cd ../
    cd PYData
    sudo ./xcode.build VERSION=${FVersion} CONFIG=${Configuration}
    cd ../
    cd PYUIKit
    sudo ./xcode.build VERSION=${FVersion} CONFIG=${Configuration}
    cd ../
elif [ "${Action}" == "List" ]; then
    echo "All Installed QTFrameworks are in the following list:"
    ls /usr/local/Frameworks/ | grep -E "^PY*.*.framework$"
elif [ "${Action}" == "Switch" ]; then
    echo "Switch to framework version: "${FVersion}
    InstallFrameworkToXcode PYCore ${FVersion}
    InstallFrameworkToXcode PYData ${FVersion}
    InstallFrameworkToXcode PYUIKit ${FVersion}
fi
