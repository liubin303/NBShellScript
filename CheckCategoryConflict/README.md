
### 检测 Category 冲突

Object-C 的 Category 初衷是为了将类分门别类的，根据功能、目的等进行分类，实现清晰整洁的编码风格。同时，该技术也能对现有的类进行扩展，扩展出方便快捷的函数。

然而过度的不正确的使用，容易导致项目中存在 Category 同名函数冲突。这种同名冲突无法自动检测，导致同名函数互相覆盖，代码最终执行到哪个具体函数不可确定。直接后果是出现不可预期的、很难排查的问题。

该脚本能够分析项目，从而进一步根据项目设置，扫描出所有系统库、依赖库，以及自身项目的中间二进制文件。
从根本上扫描所有隐患，配合 Xcode 的 Analyze 功能，最终输出 Xcode 警告。

##### 使用方法：

- 将该脚本加入项目的某个目录下，不需要添加到 Xcode。
- 在 Xcode 的对应项目 target -> Build Phases，添加一个 Shell 到最后：

```
if ( [[ "$RUN_CLANG_STATIC_ANALYZER" = YES ]]; ) then
	"${SRCROOT}/脚本相对路径"
fi
```
- 使用 XCode 的 Analyze 功能即可检测冲突。

由于该脚本扫描的文件较多，需要一些时间，因此建议根据上面的方法，只在 Analyze 才执行。


##### 可能问题

- 报错：`invalid byte sequence in US-ASCII (ArgumentError)`

    解决办法：编辑 `~/.bash_profile` 文件，在文件开始位置添加：
    ```
    export LANG=en_US.UTF-8
    export LANGUAGE=en_US.UTF-8
    export LC_ALL=en_US.UTF-8 
    ```