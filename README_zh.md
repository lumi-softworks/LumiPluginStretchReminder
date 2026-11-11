# LumiPluginStretchReminder

📖 [English](README.md) | 中文版

拉伸提醒插件的共享远程包，由 Lumi / Wakey 等 CofficLab 兄弟应用装配。

> 本插件不依赖任何其它插件。菜单栏、设置、说明书与存储全部经由 Provider 契约访问；
> 通用的提醒能力由 `LumiKitReminder` 提供。

## 包信息

- manifest 包名：`LumiPluginStretchReminder`（与仓库名一致）
- product / target：`PluginStretchReminder`
- 平台：macOS 14+
- Swift tools：6.0

## 命名约定

CofficLab 远程插件包统一遵循此约定：

| 仓库 | manifest `name:` | product / target |
| --- | --- | --- |
| `LumiPluginStretchReminder` | `LumiPluginStretchReminder` | `PluginStretchReminder` |
| `LumiPluginEyeCareReminder` | `LumiPluginEyeCareReminder` | `PluginEyeCareReminder` |
| `LumiPluginHydrationReminder` | `LumiPluginHydrationReminder` | `PluginHydrationReminder` |

原因：Xcode 的依赖列表显示的是上游 manifest 的 `Package(name:)`，而非仓库名。
manifest 包名不带 `Lumi` 前缀时，用户在 Xcode 里就看不到这个前缀了。

## 提供的能力

- 菜单栏拉伸提醒控制、状态与间隔选择。
- 设置页的提醒间隔管理与自定义间隔。
- 使用说明书条目贡献。
- 多屏拉伸提醒遮罩。
- 提醒运行态、今日次数与自定义间隔的持久化。
- 系统睡眠/唤醒后对已到期提醒的补触发。

## 依赖与接入

```swift
dependencies: [
    .package(url: "https://github.com/CofficLab/LumiPluginStretchReminder.git", from: "1.0.0")
]
```

在宿主 Factory target 中加入 product：

```swift
.product(name: "PluginStretchReminder", package: "LumiPluginStretchReminder")
```

并在插件工厂中装配：

```swift
import PluginStretchReminder

PluginStretchReminder()
```

## 品牌配置

共享包不写死任何宿主品牌，宿主通过 `StretchReminderConfiguration` 注入自己的身份：

| 字段 | 用途 | 默认值（Lumi） |
| --- | --- | --- |
| `pluginID` | 插件标识——决定启用状态与插件数据目录 | `com.coffic.lumi.plugin.stretch` |
| `loggerSubsystem` | 日志子系统——宿主的磁盘日志插件按 subsystem 前缀收集日志 | `com.coffic.lumi.plugin.stretch` |
| `accessibilityIdentifierPrefix` | 设置页控件的无障碍标识，UI 测试按它定位 | `stretch` |

默认插件 ID 是 `com.coffic.lumi.plugin.stretch`。**宿主必须注入自己的历史 ID**——
否则用户已保存的启用状态与插件专属数据目录会变成孤儿，插件看起来像是被重新安装过：

```swift
PluginStretchReminder(
    configuration: StretchReminderConfiguration(
        pluginID: "StretchReminderPlugin",
        loggerSubsystem: "com.coffic.wakey.plugin.stretch",
        accessibilityIdentifierPrefix: "wakey.stretch"
    )
)
```

宿主必须提供 `MenuBarProviding`、`SettingViewProviding`、`DocsViewProviding` 与 `StorageProviding`，
并使用 LumiUI 提供的共享设置与按钮组件。

## 本地化

字符串目录内置英文、简体中文、繁体中文（`en` / `zh-Hans` / `zh-Hant`）。
宿主无法覆盖这些文案——共享 catalog 是唯一事实来源。

## 测试

```sh
swift test
```
