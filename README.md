# LumiPluginStretchReminder

📖 English | [中文版](README_zh.md)

Shared remote package for the "Stretch Reminder" plugin, assembled by CofficLab sibling apps such as Lumi and Wakey.

> This plugin depends on no other plugins. The menu bar, settings, docs, and storage are all accessed through Provider contracts; the generic reminder capability is provided by `LumiKitReminder`.

## Package

- Manifest package name: `LumiPluginStretchReminder` (matches the repository name)
- Product / Target: `PluginStretchReminder`
- Platform: macOS 14+
- Swift tools: 6.0

## Naming Convention

CofficLab remote plugin packages follow this convention uniformly:

| Repository | manifest `name:` | product / target |
| --- | --- | --- |
| `LumiPluginStretchReminder` | `LumiPluginStretchReminder` | `PluginStretchReminder` |
| `LumiPluginEyeCareReminder` | `LumiPluginEyeCareReminder` | `PluginEyeCareReminder` |
| `LumiPluginHydrationReminder` | `LumiPluginHydrationReminder` | `PluginHydrationReminder` |

Why: Xcode's package dependency list shows the upstream manifest's `Package(name:)`, not the repository name. Without the `Lumi` prefix in the manifest package name, users would not see the prefix in Xcode.

## What It Provides

- Menu bar stretch reminder controls, status, and interval selection.
- Reminder interval management and custom intervals on the settings page.
- User manual contribution.
- Multi-screen stretch reminder overlay.
- Persistence of reminder running state, daily count, and custom intervals.
- Re-triggering of due reminders after system sleep/wake.

## Dependencies and Integration

```swift
dependencies: [
    .package(url: "https://github.com/CofficLab/LumiPluginStretchReminder.git", from: "1.0.0")
]
```

Add the product to the host Factory target:

```swift
.product(name: "PluginStretchReminder", package: "LumiPluginStretchReminder")
```

And assemble it in the plugin factory:

```swift
import PluginStretchReminder

PluginStretchReminder()
```

## Brand Configuration

The shared package hardcodes no host brand. The host injects its own identity through `StretchReminderConfiguration`:

| Field | Purpose | Default (Lumi) |
| --- | --- | --- |
| `pluginID` | Plugin identity — drives the enabled state and the plugin data directory | `com.coffic.lumi.plugin.stretch` |
| `loggerSubsystem` | Logger subsystem — the host's disk-log plugin collects logs by subsystem prefix | `com.coffic.lumi.plugin.stretch` |
| `accessibilityIdentifierPrefix` | Settings-page control identifiers used by UI tests | `stretch` |

The default plugin ID is `com.coffic.lumi.plugin.stretch`. **Hosts must inject their own historical ID** — otherwise the user's saved enabled state and plugin data directory are orphaned, and the plugin appears to have been freshly installed:

```swift
PluginStretchReminder(
    configuration: StretchReminderConfiguration(
        pluginID: "StretchReminderPlugin",
        loggerSubsystem: "com.coffic.wakey.plugin.stretch",
        accessibilityIdentifierPrefix: "wakey.stretch"
    )
)
```

The host must provide `MenuBarProviding`, `SettingViewProviding`, `DocsViewProviding`, and `StorageProviding`, and use LumiUI's shared settings and button components.

## Localization

The string catalog ships English, Simplified Chinese, and Traditional Chinese (`en` / `zh-Hans` / `zh-Hant`). Hosts cannot override these strings — the shared catalog is the single source of truth.

## Testing

```sh
swift test
```
