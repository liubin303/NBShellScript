
### 让代码获取项目当前所处的 Git 状态

将当前 Git 的 分支名、最后提交日期、Hash 存在 App 的 `Info.plist` 中

使用方法：
- 将该脚本加入项目的某个目录下，不需要添加到 Xcode。
- 在 Xcode 的对应项目 target -> `Build Phases`，添加一个 Shell 到最后：

```
"${SRCROOT}/脚本相对路径"
```

- 项目中随时可以用代码获取 Git 信息：

```
// 获取提交日期，例如 2014-11-03 15:18:25 +0800
NSString *gitCommitDate = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"GITDate"];
// 获取7位短 Hash，例如 e9c6d6a
NSString *gitRevSha     = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"GITHash"];
// 获取分支名称，例如 develop
NSString *gitCommitDate = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"GITBranch"];
```