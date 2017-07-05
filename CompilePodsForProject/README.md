
### 编译 CocoaPods 项目

使用方法：
- 编辑 XCode 的 scheme，选择主项目的 Build，在 `Build Options` 中去除 `Find implicit dependencies` 选项的勾。
- Library Search Path 中添加 `"$(CONFIGURATION_BUILD_DIR)/$(PRODUCT_NAME)-$(ARCHS)"` （注意含引号）
- Build Phases 添加一个脚本，Shell 输入 `/bin/sh`，内容输入本脚本路径，例如 `"${SRCROOT}/Resources/Shell/compile-pods-for-project.sh"` （注意含引号）
- 将刚才添加的 Script 拖动到 `Check Pods Manifest.lock` 之后

以后打开 xcodeproj 文件即可，不需要打开 workspace！
- 避免 XCode 对 Pods 项目的索引
- 避免 XCode 每次都编译 Pods （即使 Pods 未发生任何变化，XCode 也会尝试编译一遍，不过 XCode 有自己的优化机制来加速）
- 在 Pods 发生变化时候才会重新编译 Pods，保证 Pods 代码最新。

如果需要开发 Pods 或者想调试 Pods 里面的代码，也可以打开 workspace！
- 和打开 xcodeproj 不同，这种情况每次都编译 Pods，由 XCode 自己优化编译速度（会自动检测文件是否被修改）

其他优势：
- 关闭隐式依赖搜索，减少编译前卡在分析依赖时间过长
- 区分架构目录，避免每切换一次真机和模拟器都重新编译 Pods
- 启用8个线程编译 Pods 项目（默认是4线程）
