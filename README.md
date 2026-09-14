# SafetyDays — 安全天数生成器 (iOS)

> 采购部安全零事件天数自动生成器 — 每天点一下,自动计算天数、生成卡片、保存相册,直接发到微信群。

## 功能

- 自动计算从起始日(2023-05-18)到今天的天数(**统一按北京时间**,不会跨时区差一天)
- Core Graphics 绘制 **1080×1440** 卡片,与已验证的设计稿一致
- 一键生成图片并保存到 iPhone 相册,自动弹出系统分享面板
- 支持自定义标题、单位(天 / Days)

## 目录结构

```
SafetyDaysGenerator/
├── .github/workflows/build.yml   # GitHub Actions:云端编译未签名 IPA
├── project.yml                   # XcodeGen 配置(声明式)
└── SafetyDays/                   # App 源码 (SwiftUI)
    ├── SafetyDaysApp.swift       # 入口
    ├── ContentView.swift         # 主界面 + 卡片绘制 + 保存相册
    ├── Config.swift              # ★ 起始日 / 文案配置(改这里)
    ├── Info.plist                # 相册权限声明
    └── Assets.xcassets/
```

## 修改配置

打开 `SafetyDays/Config.swift`,改这几行:

```swift
static let startDateString: String = "2023-05-18"     // 起始日
static let defaultTitle: String = "采购部安全零事件已经" // 主标题
static let slogan: [String] = ["供应有保障", "安全要筑牢"]
static let company: String = "采购部"
```

改完 push 代码,Actions 会自动重新编译新 IPA。

## 构建(Windows → iPhone)

1. **改代码** → push 到 `main`
2. **GitHub Actions** 自动在云端 macOS 编译(约 3–8 分钟)
3. 进仓库 **Actions** 页 → 最新一次 Run → 底部 **Artifacts** → 下载 **SafetyDays-IPA.zip**
4. 解压得到 `SafetyDays.ipa`,用 AirDrop / 微信 / 网盘传到 iPhone
5. iPhone 上用 **TrollStore** 打开安装即可(无需签名,装一次永久使用)

本地构建(需要 Mac):

```bash
brew install xcodegen
xcodegen generate
xcodebuild -project SafetyDays.xcodeproj -scheme SafetyDays -sdk iphoneos -configuration Release CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO -derivedDataPath build
```

## 技术说明

| 项目 | 值 |
|------|-----|
| Bundle ID | com.safetydays.app |
| Min iOS | 15.0 |
| 部署目标 | iPhone only |
| 卡片尺寸 | 1080×1440 (3:4) |
| 渲染 | Core Graphics (UIGraphicsImageRenderer) |
| 保存相册 | Photos.framework(addOnly 权限) |
| 签名 | 无签名(TrollStore 安装) |
| CI | GitHub Actions macos-15 + XcodeGen |

## 常见问题

**Q: 签名会过期吗?** A: TrollStore 安装的 IPA 永久有效,不需要重新签名。

**Q: 多人安装?** A: 把 IPA 文件发给同事,各自用 TrollStore 安装即可。

**Q: 想改样式/布局?** A: 改 `ContentView.swift` 里 `renderCardImage()` 中的绘制参数。

---

祝工作顺利 🛡️