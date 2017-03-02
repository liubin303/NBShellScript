#!/bin/bash
export PATH=$PATH:/usr/local/bin/:/Users/ffan/bin/
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# 删除use_frameworks!
echo "Echo Podfile ============================================================="
sed -i '' 's/use_frameworks!//g' Podfile
cat Podfile

# 查找target
echo "Find build target ========================================================"

FIND_FILE_NAME=""
LOG_FILE_NAME="xcodeproj.log"
find . -maxdepth 1 -name "*.xcodeproj" -type d -size +0 | xargs echo "" >"${LOG_FILE_NAME}"
LOG_FIRST_LINE="1"
FIND_FILE_NAME=`sed -n $LOG_FIRST_LINE'p' "${LOG_FILE_NAME}"`
echo "$(basename $FIND_FILE_NAME .xcodeproj)"
rm -rf "${LOG_FILE_NAME}"

cd ..

FMK_NAME="$(basename $FIND_FILE_NAME .xcodeproj)"

cd $FMK_NAME

#生成头文件
echo "Create xxx-Header.h ======================================================"

HEAD_FILE=$FMK_NAME-Header.h
rm -f $HEAD_FILE

echo '//' >> ${HEAD_FILE};
echo '//  '$FMK_NAME-Header.h'' >> ${HEAD_FILE};
echo '//  '$FMK_NAME'' >> ${HEAD_FILE};
echo '//' >> ${HEAD_FILE};
echo '//  Created by shell on '$(date "+%Y/%m/%d %H:%M:%S")' ' >> ${HEAD_FILE};
echo '//  Copyright (c) '$(date "+%Y")' Wanda. All rights reserved. ' >> ${HEAD_FILE};
echo '//' >> ${HEAD_FILE};
echo '' >> ${HEAD_FILE};
echo '#ifndef '$FMK_NAME-Header_h'' >> ${HEAD_FILE};
echo '#define '$FMK_NAME-Header_h'' >> ${HEAD_FILE};
echo '' >> ${HEAD_FILE};

LIST=`find . -path */*.framework -prune -o -type f -name "*.h"`
for file_name in $LIST
do
    #echo $(basename $file_name)
    if [ -d $file_name ];then
        echo $file_name is dir
    else
        if [ ! $FMK_NAME-Header.h = $(basename $file_name) ]; then
            echo '#import "'$(basename $file_name)'"' >> ${HEAD_FILE};
        fi
    fi
done
echo '' >> ${HEAD_FILE};
echo '#endif '/*$FMK_NAME-Header_h*/'' >> ${HEAD_FILE};
echo '' >> ${HEAD_FILE};

echo $HEAD_FILE
#cat $HEAD_FILE

cd ..

BUILD_DEVICE_SDK="iphoneos"
BUILD_SIMULATOR_SDK="iphonesimulator"
BUILD_CONFIGURATION="Release"
#BUILD_CONFIGURATION="Debug"

CURRENT_DIR="$(pwd)"
BUILD_DIR="${CURRENT_DIR}/Example/Build"
DERIVED_DATA_DIR="${BUILD_DIR}/DerivedData"

BUILD_DEVICE_DIR=${DERIVED_DATA_DIR}/Build/Products/${BUILD_CONFIGURATION}-iphoneos
BUILD_SIMULATOR_DIR=${DERIVED_DATA_DIR}/Build/Products/${BUILD_CONFIGURATION}-iphonesimulator

OUT_PUT_DIR="${CURRENT_DIR}/Framework"
OUT_PUT_BUNDLE_DIR="${OUT_PUT_DIR}/${FMK_NAME}.bundle"
OUT_PUT_LIB_FILE="${OUT_PUT_DIR}/lib${FMK_NAME}.a"

# 创建输出路径
if [ ! -d "${OUT_PUT_DIR}" ];then
    mkdir -p "${OUT_PUT_DIR}"
fi

echo "Echo env paths ==========================================================="

echo CURRENT_DIR:${CURRENT_DIR}
echo BUILD_DIR:${BUILD_DIR}
echo DERIVED_DATA_DIR:${DERIVED_DATA_DIR}
echo BUILD_DEVICE_DIR:${BUILD_DEVICE_DIR}
echo BUILD_SIMULATOR_DIR:${BUILD_SIMULATOR_DIR}
echo OUT_PUT_DIR:${OUT_PUT_DIR}
echo OUT_PUT_BUNDLE_DIR:${OUT_PUT_BUNDLE_DIR}
echo OUT_PUT_LIB_FILE:${OUT_PUT_LIB_FILE}

echo "Delete Pods&Build Dir  ==================================================="

cd ${CURRENT_DIR}/Example

# 删除build
#rm -rf ./Pods/
#rm -f ./Podfile.lock
#rm -rf ./${FMK_NAME}.xcworkspace
rm -rf "${BUILD_DIR}"

echo "Install Pods ============================================================="

# install pod
pod install --no-repo-update

# build iphoneos
if [ $? -eq 0 ];then
    echo "Xcodebuild build iphoneos ================================================"
    xcodebuild -configuration ${BUILD_CONFIGURATION} -scheme ${FMK_NAME} -workspace ${FMK_NAME}.xcworkspace -sdk ${BUILD_DEVICE_SDK} build -derivedDataPath "${DERIVED_DATA_DIR}"
else
    echo "Xcodebuild build iphoneos Error !!!"
fi

# build iphonesimulator
if [ $? -eq 0 ];then
    echo "Xcodebuild  build iphonesimulator ========================================"
    xcodebuild -configuration ${BUILD_CONFIGURATION} -scheme ${FMK_NAME} -workspace ${FMK_NAME}.xcworkspace -sdk ${BUILD_SIMULATOR_SDK} build -derivedDataPath "${DERIVED_DATA_DIR}"
else
    echo "Xcodebuild build iphonesimulator Error !!!"
fi

# 删除.bundle
if [ -d "${OUT_PUT_BUNDLE_DIR}" ];then
    rm -rf "${OUT_PUT_BUNDLE_DIR}"
fi

# 删除.a
if [ -f "${OUT_PUT_LIB_FILE}" ];then
    rm -f "${OUT_PUT_LIB_FILE}"
fi

# 拷贝.bundle
cp -R "${BUILD_DEVICE_DIR}/${FMK_NAME}.bundle" "${OUT_PUT_DIR}"

echo "Delete no use files ======================================================"

# 合并.a
lipo -create "${BUILD_DEVICE_DIR}/lib${FMK_NAME}.a" "${BUILD_SIMULATOR_DIR}/lib${FMK_NAME}.a" -output "${OUT_PUT_DIR}/lib${FMK_NAME}.a"


if [ -f "${OUT_PUT_LIB_FILE}" ];then
    # 成功
	echo;echo;echo;
	echo "====================== 😄 😄 😄 😄 😄 😄  lib${FMK_NAME}.a Build  Success  😄 😄 😄 😄 😄 😄 ======================"
	echo;
	lipo -info "${OUT_PUT_LIB_FILE}"
	echo;
	echo "====================== 😄 😄 😄 😄 😄 😄  lib${FMK_NAME}.a Build  Success  😄 😄 😄 😄 😄 😄 ======================"
	echo;echo;echo;echo;echo;echo;

else
	# 失败
	echo;echo;echo;
	echo "====================== 😱 😱 😱 😱 😱 😱  lib${FMK_NAME}.a Build  Fail  😱 😱 😱 😱 😱 😱 ======================"
	echo "====================== 😱 😱 😱 😱 😱 😱  lib${FMK_NAME}.a Build  Fail  😱 😱 😱 😱 😱 😱 ======================"
	echo "====================== 😱 😱 😱 😱 😱 😱  lib${FMK_NAME}.a Build  Fail  😱 😱 😱 😱 😱 😱 ======================"
	echo;echo;echo;echo;echo;echo;

fi
