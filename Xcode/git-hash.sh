#!/bin/sh

#   git-hash.sh
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
#           NSString *gitCommitDate = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"GITBranch"];
#

INFOPLISTPATH="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"

# Get the current git commmit hash (first 7 characters of the SHA)
GITREVSHA=$(git rev-parse --short HEAD)

# Set the Git hash in the info plist for reference
defaults write "${INFOPLISTPATH}" GITHash "$GITREVSHA"

# Get the current git commit date (eg. 2014-11-03 15:18:25 +0800)
GITCOMMITDATE=$(git show -s --format=%ci HEAD)

# Set the Git date in the info plist for reference
defaults write "${INFOPLISTPATH}" GITDate "$GITCOMMITDATE"

# Get the current git branch name (eg. master)
GITBRANCH=$(git rev-parse --abbrev-ref HEAD)

# Set the Git branch name in the info plist for reference
defaults write "${INFOPLISTPATH}" GITBranch "$GITBRANCH"
