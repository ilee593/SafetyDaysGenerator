# 安全天数 · SafetyDaysGenerator

> 采购部安全零事件天数自动生成器 — **零 Mac、零付费、零 Apple ID**,在 Windows 上 push 代码,GitHub 云端 Mac 自动编译成 IPA,再通过 TrollStore 直接装到 iPhone X。

---

## 你将得到什么

```
SafetyDaysGenerator/
├── SafetyDaysGenerator/             # App 源码 (Swift / SwiftUI)
│   ├── SafetyDaysGeneratorApp.swift # 入口
│   ├── ContentView.swift            # 主界面
│   ├── PosterView.swift             # 海报视图(用 ImageRenderer 渲染)
│   ├── DayCounter.swift             # 日期 / 天数计算
│   ├── PhotoSaver.swift             # 保存到相册
│   ├── Config.swift                 # 起始日 / 文案 / 配色
│   ├── Info.plist                   # App 配置
│   └── Assets.xcassets/             # 图标 / 配色
├── project.yml                      # XcodeGen 配置(声明式)
├── .github/workflows/build.yml      # GitHub Actions(云端编译)
├── .gitignore
└── README.md                        # 本文件
```

---

## 全流程(Windows → iPhone)

```
┌──────────┐    ┌──────────┐    ┌────────────────┐
│ Windows  │───▶│  GitHub  │───▶│ macOS-14 Runner │
│ 你现在    │    │  仓库    │    │  + Xcode 15     │
└──────────┘    └──────────┘    └───────┬────────┘
                                        │ xcodebuild
                                        ▼
                                ┌──────────────┐
                                │ SafetyDays   │
                                │   .ipa       │
                                └──────┬───────┘
                                       │ AirDrop / 微信文件 / 网盘
                                       ▼
                                ┌──────────────┐
                                │   iPhone X   │
                                │  TrollStore  │
                                └──────────────┘
```

---

## 第一步 · 注册 GitHub(没有的话)

1. 打开 https://github.com/signup
2. 用邮箱注册,选 Free 套餐(完全够用)
3. 验证邮箱,设置密码

## 第二步 · 安装 Git(Windows)

如果还没装:
- 下载 https://git-scm.com/download/win
- 默认选项安装即可

打开 PowerShell,验证:
```powershell
git --version
```

## 第三步 · 创建 GitHub 仓库

1. 打开 https://github.com/new
2. 填写:
   - **Repository name**:`SafetyDaysGenerator`(随便起,但要记住)
   - **Description**:可选,写"安全天数生成器"
   - **Public** 或 **Private** 都可以(Public 别人能看到,无所谓)
   - **不要**勾选 Add a README / Add .gitignore(我们已经有)
3. 点 **Create repository**
4. 记住页面上的仓库地址,类似:
   ```
   https://github.com/你的用户名/SafetyDaysGenerator.git
   ```

## 第四步 · 上传代码

在 PowerShell 里:
```powershell
cd D:\安全天数\SafetyDaysGenerator

git init
git config user.name "你的名字"
git config user.email "你的邮箱"

# 逐个添加文件(避免误把不相关的 V1 文件也上传)
git add .github
git add SafetyDaysGenerator
git add project.yml
git add .gitignore
git add README.md

git commit -m "初次提交:安全天数 App V3"

# 关联远程仓库(替换成你自己的地址)
git remote add origin https://github.com/你的用户名/SafetyDaysGenerator.git

# 推送(main 是新仓库默认分支名)
git branch -M main
git push -u origin main
```

> **用户名密码** 第一次 push 会被要求,GitHub 现在不再支持密码,需要 **Personal Access Token**:
> 1. https://github.com/settings/tokens
> 2. Generate new token (classic)
> 3. 勾选 `repo` 全选
> 4. 生成后**复制保存**(只显示一次)
> 5. push 时 Username 填 GitHub 用户名,Password 粘贴这个 Token

## 第五步 · 触发云端编译

1. 打开你的仓库页面 → 顶部 **Actions** 标签
2. 左侧选 **Build SafetyDays IPA**
3. 右侧点 **Run workflow** → 绿色按钮 **Run workflow**
4. 等 **3–8 分钟**(首次需要装 XcodeGen)
5. 编译完成后:
   - 进这次 Run 的详情页
   - 滚到底部 **Artifacts** 区域
   - 下载 **SafetyDaysGenerator-IPA.zip**
   - 解压得到 `SafetyDaysGenerator.ipa`

> **之后每次改代码**:push 后 Actions 自动编译,不用手动 Run workflow

## 第六步 · 把 IPA 传到 iPhone

任选一种:
- **AirDrop**(最方便,iPhone 接收即可)
- **微信文件传输助手**(自己发给自己)
- **百度网盘 / iCloud Drive**(大文件慢但稳)
- **GitHub Releases**(每次编译后自动发到 Release,长按下载链接 → Safari 打开 → 下载)

## 第七步 · TrollStore 安装

> ⚠️ **前提**:你的 iPhone X 已经装好 TrollStore
> - iPhone X 最高 iOS 16.x
> - TrollStore 2 支持 iOS 15.2 – 16.5
> - **如果你的 iPhone X 是 iOS 16.6+**,TrollStore 用不了,需要走普通自签名方案

安装步骤:
1. iPhone 上打开 IPA 文件
2. 系统弹窗 → 选 **共享 / Open in...**
3. 列表里选 **TrollStore**
4. TrollStore 弹窗 → 点 **Install**
5. 桌面出现"安全天数"图标
6. 打开 → 允许访问相册 → 点"保存到相册" → 完成

> 之后这个 IPA 可以无限期使用,签名不过期。
> 改代码后重新 push,会自动生成新 IPA,重新装一次即可。

---

## 每天怎么用

1. 打开"安全天数" App
2. 看一眼显示的今天天数(自动计算)
3. 点 **"保存到相册"**
4. 弹系统授权框 → 选"允许"
5. Toast 提示已保存
6. 打开微信群 → + → 相册 → 选那张图 → 发送

**每天 5 秒搞定,不需要 Mac,不需要重新签名。**

---

## 如何修改配置(标题、文案、起始日、颜色)

打开 `SafetyDaysGenerator/Config.swift`,改这几行:

```swift
static let startDateString: String = "2023-05-18"            // 起始日
static let title: String = "采购部安全零事件已经"              // 主标题
static let slogan: [String] = ["供应有保障", "安全要筑牢"]    // 气泡标语
static let company: String = "采购部"                        // 底部署名
```

改完 push 代码,Actions 自动重新编译,下个新 IPA 重装即可。

如果想改颜色 / 字号 / 布局,改 `PosterView.swift`。

---

## 常见问题

### Q1: Actions 编译失败,日志里一堆红色?
最常见原因:
- **拼写错误**:`xcodebuild` 报错行数 → 找对应文件修正 → 再 push
- **Xcode 版本**:我在 workflow 里钉死 `Xcode_15.4`,如果有更新需求改那一行

### Q2: iPhone X 是 iOS 16.6+,TrollStore 装不上怎么办?
两个选择:
- **方案 A**(推荐):找一台 iOS 16.5 及以下的旧 iPhone 装上(只要装一次就行)
- **方案 B**:走普通自签名 — 编译时打开代码签名,用免费 Apple ID 签 7 天
  - 改 `build.yml`,把 `CODE_SIGN_IDENTITY=""` 改成你证书名
  - 把 `.p12` 和 `.mobileprovision` 加到仓库 Secrets 里
  - 步骤更复杂,我可以单独再出一份教程

### Q3: 能不能多人用(给同事也装)?
可以。两种方式:
- **简单**:把 IPA 文件发给他们,各自用自己 iPhone 上的 TrollStore 装
- **正式**:申请 Apple 付费开发者账号(¥688/年),走 App Store 或企业分发

### Q4: 改了代码 push 上去 Actions 没反应?
检查:
- 默认 branch 是 `main`(2020 年后 GitHub 默认就是 main)
- 进 Actions 页面,看是不是有红色 ✗ 的失败记录
- 如果 push 到 `master` 分支而 workflow 只监听 `main`,改成匹配

### Q5: Actions 每个月有免费额度吗?
**GitHub Actions 免费额度**:
- 公开仓库:**无限**
- 私有仓库:**每月 2000 分钟**(macOS runner 是按 10 倍计,实际 200 分钟)
- 编译一次大约 3–5 分钟,**足够每月 40+ 次编译**

完全够用。

### Q6: 不想用 GitHub,还有别的云端 Mac 方案?
- **Codemagic**:100% 免费 macOS 构建,每月 500 分钟
- **Bitrise**:每月有限免费额度
- **Appcircle**:免费 2000 分钟/月
- 但 GitHub Actions 最稳,我推荐这个

---

## 项目特色

- ✅ **iOS 16+ SwiftUI 现代化开发**,Apple 官方推荐架构
- ✅ **ImageRenderer** 把 SwiftUI 视图渲染为高清 PNG,2x scale = 2160×2880
- ✅ **Photos.framework** 异步保存,自动处理权限
- ✅ **XcodeGen** 声明式配置,`.xcodeproj` 现场生成,代码可读性极强
- ✅ **零 Mac 零付费**:GitHub 提供 macOS Runner,自带 Xcode 15
- ✅ **TrollStore 永久安装**:装一次,终身可用
- ✅ **离线工作**:打开 App 不需要网络

---

## 技术细节

| 项目 | 值 |
|------|-----|
| Bundle ID | com.safetydays.app |
| Min iOS | 16.0(iPhone X 最高 16) |
| 部署目标 | iPhone only(TARGETED_DEVICE_FAMILY=1) |
| 海报尺寸 | 1080×1440(3:4,@2x = 2160×2880) |
| 签名 | 无签名(TrollStore 用 CoreTrust 漏洞重签) |
| CI | GitHub Actions macos-14 + Xcode 15.4 |

---

## 下一步

- 想加 **多个里程碑**(每个部门一个计数)?改 `Config.swift` 加 enum。
- 想加 **微信分享按钮**?`ContentView.swift` 里已经有 `ShareSheet`,复制图片到微信即可。
- 想加 **每日提醒**(早上自动弹通知)?用 `UserNotifications`,需要权限。

需要我帮你做这些,随时告诉我。

祝工作顺利 🛡️
