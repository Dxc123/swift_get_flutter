# swift_get

`swift-get` 是一个用 Dart 编写的命令行工具，用来快速生成 Swift UIKit iOS 应用脚手架、功能模块和轻量页面。生成代码默认采用 UIKit、MVVM、Coordinator 导航和 SnapKit 约束风格，适合作为 iOS 原生项目的起步模板或模块化开发辅助工具。

## 功能特性

- 生成 UIKit iOS 应用基础结构。
- 生成 `ViewController`、`View`、`ViewModel`、`Coordinator` 组成的功能模块。
- 支持生成不带 `Service` 的轻量页面。
- 支持 `--dry-run` 预览将要创建的文件。
- 支持 `--force` 覆盖已存在文件。
- 内置基础名称校验和模板渲染能力。

## 环境要求

- Dart SDK `^3.11.0`
- Xcode，用于打开和构建生成后的 iOS 工程

生成的 Swift 项目基线：

- UIKit
- MVVM
- Coordinator
- SnapKit
- iOS 15+

## 安装与运行

在仓库目录中可以直接通过 Dart 运行：

```bash
dart run bin/swift_get.dart --help
```

也可以本地激活为全局命令：

```bash
dart pub global activate --source path .
swift-get --help
```

如果激活后终端找不到 `swift-get`，请确认 Dart 全局可执行文件目录已经加入 `PATH`。

## 命令用法

### 创建 iOS 应用

```bash
swift-get create DemoApp --bundle-id com.example.demo --path /tmp
```

等价的未激活运行方式：

```bash
dart run bin/swift_get.dart create DemoApp --bundle-id com.example.demo --path /tmp
```

常用参数：

| 参数 | 说明 |
| --- | --- |
| `AppName` | 应用名称，必填，例如 `DemoApp` |
| `--bundle-id` | Bundle Identifier，必填，例如 `com.example.demo` |
| `--org` | 组织名称，默认 `Generated` |
| `--path` | 输出目录，默认当前目录 |
| `--dry-run` | 只打印将要创建的文件，不写入磁盘 |
| `--force` | 覆盖已存在文件 |

生成后的目录大致如下：

```text
DemoApp/
  DemoApp/
    App/
      AppDelegate.swift
      SceneDelegate.swift
      AppCoordinator.swift
    Modules/
      Home/
        HomeViewController.swift
        HomeView.swift
        HomeViewModel.swift
    Resources/
      Info.plist
  DemoAppTests/
    DemoAppTests.swift
  DemoApp.xcodeproj/
    project.pbxproj
  README.md
```

### 生成功能模块

```bash
swift-get generate module Login --project /tmp/DemoApp/DemoApp/Modules
```

`generate module` 会生成完整模块文件：

```text
Login/
  LoginViewController.swift
  LoginView.swift
  LoginViewModel.swift
  LoginCoordinator.swift
  LoginService.swift
```

参数说明：

| 参数 | 说明 |
| --- | --- |
| `ModuleName` | 模块名称，必填，例如 `Login` |
| `--project` | 模块输出目录，默认当前目录 |
| `--dry-run` | 只打印将要创建的文件，不写入磁盘 |
| `--force` | 覆盖已存在文件 |

### 生成轻量页面

```bash
swift-get generate page Profile --project /tmp/DemoApp/DemoApp/Modules --module Account
```

`generate page` 会生成不带 `Service` 的页面结构：

```text
Account/
  Profile/
    ProfileViewController.swift
    ProfileView.swift
    ProfileViewModel.swift
    ProfileCoordinator.swift
```

参数说明：

| 参数 | 说明 |
| --- | --- |
| `PageName` | 页面名称，必填，例如 `Profile` |
| `--project` | 输出根目录，默认当前目录 |
| `--module` | 可选。指定后页面会生成到 `--project/<module>/<PageName>` 下 |
| `--dry-run` | 只打印将要创建的文件，不写入磁盘 |
| `--force` | 覆盖已存在文件 |

## 使用示例

先预览创建应用：

```bash
swift-get create DemoApp --bundle-id com.example.demo --path /tmp --dry-run
```

确认无误后真正写入：

```bash
swift-get create DemoApp --bundle-id com.example.demo --path /tmp
```

继续添加登录模块：

```bash
swift-get generate module Login --project /tmp/DemoApp/DemoApp/Modules
```

在 `Account` 模块下添加资料页：

```bash
swift-get generate page Profile --project /tmp/DemoApp/DemoApp/Modules --module Account
```

## 项目结构

```text
bin/
  swift_get.dart                    # CLI 入口
lib/src/
  commands/                         # 命令解析与命令实现
  scaffold/                         # 应用、模块、页面脚手架规划
  xcode/                            # Xcode 工程编辑入口
  file_writer.dart                  # 文件写入与 dry-run 支持
  name_validator.dart               # 名称与 bundle id 校验
  template_renderer.dart            # 简单 {{variable}} 模板渲染
test/                               # 单元测试与集成测试
```

## 开发与验证

安装依赖：

```bash
dart pub get
```

运行测试：

```bash
dart test
```

静态分析：

```bash
dart analyze
```

查看 CLI 帮助：

```bash
dart run bin/swift_get.dart --help
```

## 当前实现边界

当前版本会生成确定性的最小 `.xcodeproj/project.pbxproj`，并通过 `XcodeProjectEditor` 输出或记录目标、测试目标和 SnapKit Swift Package 的编辑意图。完整的 Xcode target membership、Swift Package 引用和真实工程对象变更仍属于后续完善方向。

因此，生成项目后如果需要立即在 Xcode 中完整构建，可能还需要根据实际工程状态手动补齐 target 文件归属和 Swift Package 配置。

## 许可证

当前仓库尚未声明许可证。如需发布或分发，请先补充许可证文件。
