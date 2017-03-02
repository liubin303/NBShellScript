#!/bin/sh

#   build_config.sh
#   FeiFan
#
#   用于获取项目当前所处的 Git 状态
#
#   将当前 Git 的 分支名、最后提交日期、Hash 存在 App 的 Info.plist 中
#
#   使用方法：
#       1. 将该脚本加入项目的某个目录下，不需要添加到 Xcode。
#       2. 在 Xcode 的对应项目 target -> Build Phases，添加一个 Shell 到最后：
#           "${SRCROOT}/脚本相对路径"
#       3. 项目中随时可以用代码获取 Git 信息：
#           // 获取提交日期，例如 2014-11-03 15:18:25 +0800
#           NSString *gitCommitDate = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"GITDate"];
#           // 获取7位短 Hash，例如 e9c6d6a
#           NSString *gitRevSha     = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"GITHash"];
#           // 获取分支名称，例如 develop
#           NSString *gitBranchName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"GITBranch"];
#

# info.plist路径
INFOPLISTPATH="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
# if [ "${CONFIGURATION}" = "Release" ]; then

# 设置git当前分支名
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
defaults write "${INFOPLISTPATH}" GITBranch "$GIT_BRANCH"

# 设置git提交总数
GIT_COMMIT_COUNT=$(git rev-list HEAD | wc -l | sed -e 's/ *//g' | xargs -n1 printf %d)
defaults write "${INFOPLISTPATH}" GITCommitCount "$GIT_COMMIT_COUNT"

# 设置git最后提交的hash编码
GIT_REV_SHA=$(git rev-parse --short HEAD)
defaults write "${INFOPLISTPATH}" GITHash "$GIT_REV_SHA"

# 设置git最后提交的时间
GIT_COMMIT_DATE=$(git show -s --format=%ci HEAD)
defaults write "${INFOPLISTPATH}" GITDate "$GIT_COMMIT_DATE"

# buildNumber自动叠加
OLD_BUILD_NUMBER=`/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "${INFOPLISTPATH}"`
NEW_BUILD_NUMBER=$(($OLD_BUILD_NUMBER + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${NEW_BUILD_NUMBER}" "${INFOPLISTPATH}"

open ${INFOPLISTPATH}

# fi
