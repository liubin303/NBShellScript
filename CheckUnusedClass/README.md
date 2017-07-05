
### 检测未使用的类

本脚本用于扫描未被其他文件 import 的类文件。

注意：

	1. 通过是否被其他文件 import 来判断文件是否被使用
	- Category 不需要都 import，因此 Category 会被误扫描
	- 使用运行时进行映射的类，也存在误扫描问题

##### 使用方法：

- 需要 Ruby 的依赖 `fui`：
	```
	gem install fui
	```
	
- 将该脚本加入项目的某个目录下，不需要添加到 Xcode。
- 在 Xcode 的对应项目 target -> Build Phases，添加一个 Shell 到最后：

```
if ( [[ "$RUN_CLANG_STATIC_ANALYZER" = YES ]]; ) then
	"${SRCROOT}/脚本相对路径"
fi
```
- 使用 XCode 的 Analyze 功能即可。

由于该脚本扫描的文件较多，需要一些时间，因此建议根据上面的方法，只在 Analyze 才执行。

