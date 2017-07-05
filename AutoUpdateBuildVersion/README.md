
### 自动更新 Build 版本号

将当前日期保存到输出信息的 `Info.plist` 中，不修改源代码的版本设置，直接应用于输出的 plist

使用方法：
- 将该脚本加入项目的某个目录下，不需要添加到 Xcode。
- 在 Xcode 的对应项目 target -> `Build Phases`，添加一个 Shell 到最后：

```
"${SRCROOT}/脚本相对路径"
```
