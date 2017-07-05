#!/bin/sh

#  compile-pods-for-project.sh
#  Taobao4iPad
#
#  Created by Whirlwind on 15/4/22.
#  Copyright (c) 2015年 Taobao.com. All rights reserved.
#
#   该脚本用于编译 CocoaPods 项目。
#
#   使用方法：
#       1. Library Search Path 中添加 "$(CONFIGURATION_BUILD_DIR)/$(PRODUCT_NAME)-$(ARCHS)" （注意含引号）
#       2. Build Phases 添加一个脚本，Shell 输入 /bin/sh，内容输入本脚本路径，例如 "${SRCROOT}/Resources/Shell/compile-pods-for-project.sh" （注意含引号）
#       3. 将刚才添加的 Script 拖动到 Check Pods Manifest.lock 之后
#
#   以后打开 xcodeproj 文件即可，不需要打开 workspace！
#       1. 避免 XCode 对 Pods 项目的索引
#       2. 避免 XCode 每次都编译 Pods （即使 Pods 未发生任何变化，XCode 也会尝试编译一遍，不过 XCode 有自己的优化机制来加速）
#       3. 在 Pods 发生变化时候才会重新编译 Pods，保证 Pods 代码最新。
#
#   如果需要开发 Pods 或者想调试 Pods 里面的代码，也可以打开 workspace！
#       1. 和打开 xcodeproj 不同，这种情况每次都编译 Pods，由 XCode 自己优化编译速度（会自动检测文件是否被修改）
#
#   其他优势：
#       1. 区分架构目录，避免每切换一次真机和模拟器都重新编译 Pods
#       2. 启用8个线程编译 Pods 项目（默认是4线程）
#


# 将 libPods.a 放在当前架构目录下面，可以避免切换架构（例如真机切换到模拟器）需要重新编译
PODS_CONFIGURATION_BUILD_LINK="${CONFIGURATION_BUILD_DIR}/${PRODUCT_NAME}-${ARCHS}"
PODS_CONFIGURATION_BUILD_DIR="${PODS_CONFIGURATION_BUILD_LINK}-Project"
LOCK_FILE="${PODS_CONFIGURATION_BUILD_DIR}/Podfile.lock"

rm -rf "${PODS_CONFIGURATION_BUILD_LINK}" || true

# 判断当前 XCode 打开的是工作空间还是项目
# 如果是工作空间，每次都编译 Pods，因为可能是开发 Pods
workspecname=`osascript << EOT
tell application id "com.apple.dt.Xcode"
set workspecname to active workspace document
end tell
return workspecname
EOT`

if [[ "$workspecname" != *"project.xcworkspace"* ]] && [[ "$workspecname" != *".xcodeproj"* ]]; then
    echo "You are using workspace, Skip."
    exit 0
fi

echo "Pods 输出路径: ${PODS_CONFIGURATION_BUILD_DIR}"

# 清理 Pods，XCode 可能执行过 clean
if ( ! [ -d "${CONFIGURATION_BUILD_DIR}/${PRODUCT_NAME}.app" ] ) then
    rm -rf "${PODS_CONFIGURATION_BUILD_DIR}" || true
fi

# 清理 XCode 原来生成的 Pods，防止冲突
rm -rf "${CONFIGURATION_BUILD_DIR}/libPods"* || true

# 比较 Podfile.lock 是否变动，变动则需要编译 Pods
if ( [ -f "${LOCK_FILE}" ] ) then
    diff "${PODS_ROOT}/Manifest.lock" "${LOCK_FILE}" > /dev/null
    if [[ $? = 0 ]] ; then
        ln -s "${PODS_CONFIGURATION_BUILD_DIR}" "${PODS_CONFIGURATION_BUILD_LINK}"
        echo "Podfile.lock NOT changed. Skip build."
        exit 0
    else
        echo "Podfile.lock changed. I will build Pods."
    fi
else
    echo "Lock file NOT found. I will build Pods."
    echo "${LOCK_FILE}"
fi

xcodebuild -project "${PODS_ROOT}/Pods.xcodeproj" -alltargets -parallelizeTargets -jobs 8 ARCHS="${ARCHS}" ONLY_ACTIVE_ARCH=NO -sdk ${SDK_NAME} -configuration ${CONFIGURATION} SHARED_PRECOMPS_DIR="${SHARED_PRECOMPS_DIR}" CONFIGURATION_BUILD_DIR="${PODS_CONFIGURATION_BUILD_DIR}" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO EXPANDED_CODE_SIGN_IDENTITY="" PROJECT_TEMP_DIR="${PROJECT_TEMP_ROOT}/Pods.build"

if [ "$?" = "0" ]; then
    cp "${PODS_ROOT}/Manifest.lock" "${LOCK_FILE}"
    ln -s "${PODS_CONFIGURATION_BUILD_DIR}" "${PODS_CONFIGURATION_BUILD_LINK}"
else
    exit 1
fi
