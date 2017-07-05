### 自动拷贝 Framework 的资源

Framework 一般带有资源文件，位于 `xx.framework/Resources` 目录下。

在 XCode 中手动引入 Framework 时 （在 `Link Frameworks and Libraries` 中添加），XCode 只是简单的链接二进制，并不会拷贝资源文件到主项目！

如果使用 CocoaPods 管理依赖，CocoaPods 会有一个 `copy-resources.sh` 脚本来拷贝资源；如果不是使用 CocoaPods，则可以使用本脚本自动拷贝 Framework 中的资源。

##### 使用方法：

- 将该脚本加入项目的某个目录下，不需要添加到某个 Target 。
- 在 Xcode 的对应项目 `target` -> `Build Phases`，添加一个 Shell 到最后：（脚本路径根据情况决定）

```
bash -l -c ruby "${SRCROOT}/copy-framework-resources.rb"
```

*注：本项目需要 `xcodeproj` 库，该库由 `CocoaPods` 自带。*

##### 可能问题

- 报错：`invalid byte sequence in US-ASCII (ArgumentError)`

    解决办法：编辑 `~/.bash_profile` 文件，在文件开始位置添加：
    ```
    export LANG=en_US.UTF-8
    export LANGUAGE=en_US.UTF-8
    export LC_ALL=en_US.UTF-8 
    ```