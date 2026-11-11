import Foundation
import KernelCore
import ProviderDocsView
import ProviderMenuBar
import ProviderSettingView
import Testing
@testable import PluginStretchReminder

/// 共享包的「品牌参数化」守卫。
///
/// 宿主（Lumi / Wakey / …）各自拥有不同的插件 id 与日志子系统。若插件把
/// 这些值写死，宿主一旦换 id，用户已保存的启用状态与插件专属数据目录
/// 就会「凭空消失」——插件看起来被重装了。因此这里验证：
/// 宿主注入的 id 必须贯穿插件的每一处对外标识。
@Suite("PluginStretchReminder 品牌参数化")
@MainActor
struct PluginStretchReminderConfigurationTests {
    @Test("默认配置使用 Lumi 品牌 id")
    func defaultConfigurationUsesLumiBrand() {
        let configuration = StretchReminderConfiguration()
        #expect(configuration.pluginID == "com.coffic.lumi.plugin.stretch")
        #expect(configuration.loggerSubsystem == "com.coffic.lumi.plugin.stretch")
    }

    @Test("注入自定义 id 后插件的对外标识全部跟随")
    func injectedIDPropagatesToContributions() throws {
        let kernel = KernelCoreContainer()
        let popups = DefaultMenuBarProviding()
        let settings = DefaultSettingViewProviding()
        let docs = DefaultDocsViewProviding()
        try kernel.registerProvider(MenuBarProviding.self, popups)
        try kernel.registerProvider((any SettingViewProviding).self, settings)
        try kernel.registerProvider((any DocsViewProviding).self, docs)

        let plugin = PluginStretchReminder(
            configuration: StretchReminderConfiguration(
                pluginID: "StretchReminderPlugin",
                loggerSubsystem: "com.coffic.wakey.plugin.stretch",
                accessibilityIdentifierPrefix: "wakey.stretch"
            )
        )

        try kernel.start(plugins: [plugin])

        // 插件自身 id
        #expect(plugin.id == "StretchReminderPlugin")
        // 元数据 id
        #expect(plugin.metadata.id == "StretchReminderPlugin")
        // 设置入口 id
        #expect(settings.entries.first?.id == "StretchReminderPlugin")
        // 状态栏弹窗 id 与归属
        #expect(popups.popupItems.first?.id == "StretchReminderPlugin.popup")
        #expect(popups.popupItems.first?.ownerPluginID == "StretchReminderPlugin")
        // 说明书条目 id
        #expect(docs.manualEntries.first?.id == "StretchReminderPlugin")

        try kernel.stop()
    }

    @Test("不同宿主可以并存不同 id，互不覆盖")
    func differentHostsUseDistinctIDs() throws {
        let kernel = KernelCoreContainer()
        let settings = DefaultSettingViewProviding()
        try kernel.registerProvider((any SettingViewProviding).self, settings)

        let lumi = PluginStretchReminder()
        let wakey = PluginStretchReminder(
            configuration: StretchReminderConfiguration(
                pluginID: "StretchReminderPlugin",
                loggerSubsystem: "com.coffic.wakey.plugin.stretch"
            )
        )

        try kernel.start(plugins: [lumi, wakey])

        let ids = Set(settings.entries.map(\.id))
        #expect(ids.contains("com.coffic.lumi.plugin.stretch"))
        #expect(ids.contains("StretchReminderPlugin"))

        try kernel.stop()
    }

    @Test("启用策略可由宿主覆盖")
    func policyIsConfigurable() {
        let alwaysOn = PluginStretchReminder(policy: .alwaysOn)
        #expect(alwaysOn.metadata.policy == .alwaysOn)

        let defaultPolicy = PluginStretchReminder()
        #expect(defaultPolicy.metadata.policy == .enabledByDefault)
    }

    @Test("启动顺序可由宿主覆盖")
    func orderIsConfigurable() {
        #expect(PluginStretchReminder().order == 9)
        #expect(PluginStretchReminder(order: 42).order == 42)
    }
}
