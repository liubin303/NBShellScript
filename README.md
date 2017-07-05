## XCode 一些比较有用的脚本

- auto-update-build-version.sh

    将当前日期保存到输出信息的 Info.plist 中，不修改源代码的版本设置，直接应用于输出的 plist

- check_unused_class.sh

    用于扫描未被其他文件 import 的类文件。对于不需要 import 的类（Category、运行时映射的类）存在误扫描问题。

- check-category-conflict.rb

	智能检测项目中存在的 Category 注入的函数是否存在隐式冲突，包括与系统函数冲突

- git-hash.sh

	让程序在运行时能获取当前代码是哪个 Git 分支(版本)，存在 App 的 Info.plist 中。对于开发环境下显示项目版本号比较有用

- compile-pods-for-project.sh
	
	预编译 CocoaPods 的 Pods 项目，不用 workspace ，使用 project 也能运行项目，减少 XCode 每次索引和编译时间，对于依赖过多的项目效果明显

- copy-framework-resources.rb

	在 XCode 中手动引入 Framework 时 （在 Link Frameworks and Libraries 中添加），XCode 只是简单的链接二进制，并不会拷贝资源文件到主项目！该脚本能够自动拷贝依赖的 `framework` 内的资源文件到 `app` 目录下

	
### 使用方法：

1. 直接下载需要的脚本放在项目中，推荐使用 Git 的 SubModule，方便跟踪本项目的更新状态：
```
git submodule add git@gitlab.alibaba-inc.com:chijing.zcj/XCodeScript.git XCodeScript
```
- 根据脚本内开头的注释操作即可

### 提醒：

* 如果将脚本 add 到 xcode 的项目中，务必去除 target 的勾！！*

* 如果提示无权限，请执行 （使用 Git Submodule 自带权限）
```
chmod +x 脚本路径
```
* 报错：invalid byte sequence in US-ASCII (ArgumentError), 解决办法：编辑 ~/.bash_profile 文件，在文件开始位置添加：
```
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8 
```