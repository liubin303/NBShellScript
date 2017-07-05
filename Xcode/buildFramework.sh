#!/bin/bash
export PATH=$PATH:/usr/local/bin/:/Users/ffan/bin/
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

FIND_FILE_NAME=""
LOG_FILE_NAME="xcodeproj.log"
find . -maxdepth 1 -name "*.xcodeproj" -type d -size +0 | xargs echo "" >"${LOG_FILE_NAME}"
LOG_FIRST_LINE="1"
FIND_FILE_NAME=`sed -n $LOG_FIRST_LINE'p' "${LOG_FILE_NAME}"`
echo "$(basename $FIND_FILE_NAME .xcodeproj)"
rm -rf "${LOG_FILE_NAME}"

cd ..

FMK_NAME="$(basename $FIND_FILE_NAME .xcodeproj)"

BUILD_DEVICE_SDK="iphoneos"
BUILD_SIMULATOR_SDK="iphonesimulator"
BUILD_CONFIGURATION="Release"
#BUILD_CONFIGURATION="Debug"

CURRENT_DIR="$(pwd)"
BUILD_DIR="${CURRENT_DIR}/Example/Build"
DERIVED_DATA_DIR="${BUILD_DIR}/DerivedData"

BUILD_DEVICE_DIR=${DERIVED_DATA_DIR}/Build/Products/${BUILD_CONFIGURATION}-iphoneos/${FMK_NAME}.framework
BUILD_SIMULATOR_DIR=${DERIVED_DATA_DIR}/Build/Products/${BUILD_CONFIGURATION}-iphonesimulator/${FMK_NAME}.framework

OUT_PUT_DIR="${CURRENT_DIR}/Framework"
OUT_PUT_FMK_DIR="${OUT_PUT_DIR}/${FMK_NAME}.framework"

if [ ! -d "${OUT_PUT_DIR}" ];then
mkdir -p "${OUT_PUT_DIR}"
fi

echo "Echo Paths ============================================="

echo ${CURRENT_DIR}
echo ${BUILD_DIR}
echo ${DERIVED_DATA_DIR}
echo ${BUILD_DEVICE_DIR}
echo ${BUILD_SIMULATOR_DIR}
echo ${OUT_PUT_DIR}
echo ${OUT_PUT_FMK_DIR}

echo "Echo Paths ============================================="

cd ${CURRENT_DIR}/Example

echo "Delete Pods Build ============================================="

#rm -rf ./Pods/
#rm -f ./Podfile.lock
#rm -rf ./${FMK_NAME}.xcworkspace
rm -rf "${BUILD_DIR}"

echo "Install Pods ============================================="

pod install --no-repo-update

if [ $? -eq 0 ];then
echo "Xcodebuild build iphoneos ============================================="
xcodebuild -configuration ${BUILD_CONFIGURATION} -scheme ${FMK_NAME} -workspace ${FMK_NAME}.xcworkspace -sdk ${BUILD_DEVICE_SDK} build -derivedDataPath "${DERIVED_DATA_DIR}"
else
echo "Xcodebuild build iphoneos Error !!!"
fi

if [ $? -eq 0 ];then
echo "Xcodebuild  build iphonesimulator ============================================="
xcodebuild -configuration ${BUILD_CONFIGURATION} -scheme ${FMK_NAME} -workspace ${FMK_NAME}.xcworkspace -sdk ${BUILD_SIMULATOR_SDK} build -derivedDataPath "${DERIVED_DATA_DIR}"
else
echo "Xcodebuild build iphonesimulator Error !!!"
fi

if [ -d "${OUT_PUT_FMK_DIR}" ];then
rm -rf "${OUT_PUT_FMK_DIR}"
fi

mkdir -p "${OUT_PUT_FMK_DIR}"
cp -R "${BUILD_DEVICE_DIR}/" "${OUT_PUT_FMK_DIR}/"

echo "DELETE no use files ============================================="
rm -f "${OUT_PUT_FMK_DIR}/Info.plist"
rm -rf "${OUT_PUT_FMK_DIR}/Modules"

lipo -create "${BUILD_DEVICE_DIR}/${FMK_NAME}" "${BUILD_SIMULATOR_DIR}/${FMK_NAME}" -output "${OUT_PUT_FMK_DIR}/${FMK_NAME}"

if [ -f "${OUT_PUT_FMK_DIR}/${FMK_NAME}" ];then
#rm -rf "${BUILD_DIR}"

echo;echo;echo;
echo "====================== 😄 😄 😄 😄 😄 😄  ${FMK_NAME}.framework Build  Success  😄 😄 😄 😄 😄 😄 ======================"
echo;
lipo -info "${OUT_PUT_FMK_DIR}/${FMK_NAME}"
echo;
echo "====================== 😄 😄 😄 😄 😄 😄  ${FMK_NAME}.framework Build  Success  😄 😄 😄 😄 😄 😄 ======================"
echo;echo;echo;echo;echo;echo;

#open "${OUT_PUT_FMK_DIR}"

else
echo;echo;echo;
echo "====================== 😱 😱 😱 😱 😱 😱  ${FMK_NAME}.framework Build  Fail  😱 😱 😱 😱 😱 😱======================"
echo "====================== 😱 😱 😱 😱 😱 😱  ${FMK_NAME}.framework Build  Fail  😱 😱 😱 😱 😱 😱======================"
echo "====================== 😱 😱 😱 😱 😱 😱  ${FMK_NAME}.framework Build  Fail  😱 😱 😱 😱 😱 😱======================"
echo;echo;echo;echo;echo;echo;

fi

