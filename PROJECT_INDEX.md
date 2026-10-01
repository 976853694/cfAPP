# Orange Cloud — 项目索引

> Cloudflare 第三方客户端。四端原生实现（iOS / Android / HarmonyOS / Web），
> 以 Cloudflare 官方 **OAuth 2.0 + PKCE** 登录，无需手动粘贴 API Token。
>
> 索引生成时间：2026-10-01 · 分支 `main` · 最新提交 `2ebe5b0 0.2`

---

## 1. 项目概览

| 项目 | 说明 |
| --- | --- |
| 名称 | Orange Cloud（`orange-cloud`） |
| 定位 | iPhone / iPad / Apple Watch + Android + HarmonyOS 的 Cloudflare 管理客户端 |
| 官网 | https://o-c.do |
| App Store | id6779323783 |
| 作者 | chen2he \<z@hz.do\> · © 2026 柘家科技有限公司 (Zhe Tech Co., Ltd.) |
| 许可 | **AGPL-3.0 + Commons Clause**（禁止商业销售，其余照 AGPL） |
| 开源解锁 | 编译条件 `OPENSOURCE_UNLOCKED` / Gradle `oss` flavor → 零成本解锁全部 Pro 功能 |
| 本地化 | 13 种语言：en, zh-Hans, zh-Hant, zh-HK, ja, es-MX, ko, pt-BR, pt-PT, de, fr, ar, tr |

**功能域**：域名与网络（DNS / 缓存规则 / 负载均衡 / 批量重定向）、开发者平台（Workers & Pages / 实时日志 / Snippets）、存储（R2 / D1 / KV / 文件 App 挂载）、安全与 Zero Trust（WAF / Tunnel / SSL）、流量分析（GraphQL + Swift Charts）、系统集成（小组件 / 控制中心 / Siri / Live Activity）。

---

## 2. 技术栈

| 端 | 语言 / 框架 | 关键依赖 |
| --- | --- | --- |
| iOS / watchOS | Swift 6 + SwiftUI（Xcode 工程） | iOS 17 基线，watchOS 10.6，渐进增强 iOS 18/26 |
| Android | Kotlin + Jetpack Compose | Hilt、KSP、Kotlin Serialization、Room、Material You |
| HarmonyOS | ArkTS（.ets）+ ArkUI | Stage 模型，`entry` 模块 + Widget |
| Web | TypeScript + Next.js 16（App Router）+ React 19 | next-intl、Tailwind 4、jose、@peculiar/x509 |
| 官网部署 | OpenNext on **Cloudflare Workers** | wrangler、D1（migrations） |
| 工程化 | pnpm workspaces + Turborepo | pnpm@11.5.1、turbo@2.5、Node 22（.nvmrc） |

---

## 3. Monorepo 结构

```
cfAPP/  (orange-cloud)
├── apps/
│   ├── ios/          # Swift/SwiftUI：主 App + Watch App + 文件扩展
│   ├── android/      # Kotlin/Compose：功能对齐 iOS
│   ├── harmonyos/    # ArkTS/ArkUI：鸿蒙端
│   └── web/          # Next.js：官网落地页 + OAuth 回调中转 + 交易/激活后端
├── packages/
│   └── changelog/    # 发布说明单一数据源（iOS/Android/HarmonyOS JSON + codegen）
├── package.json      # pnpm workspaces 根
├── pnpm-workspace.yaml
├── turbo.json
├── CONTRIBUTING.md / CLA.md / TRADEMARK.md / LICENSE
└── .github/ISSUE_TEMPLATE/
```

### 代码规模（不含 node_modules / build）

| 类型 | 数量 |
| --- | --- |
| Swift | 380 |
| Kotlin | 262 |
| ArkTS (.ets) | 174 |
| TypeScript (.ts) | 120 |
| TSX (.tsx) | 116 |
| JSON | 55 · YAML 8 · Markdown 7 |

---

## 4. 各端详解

### 4.1 `apps/ios/` — Swift / SwiftUI

```
apps/ios/Orange Cloud/
├── Orange Cloud.xcodeproj
├── Orange Cloud/            # 主 App target
│   ├── Orange_CloudApp.swift / ContentView.swift
│   ├── Core/                # 基础设施层
│   │   ├── Auth/ Crypto/ Network/ Cache/ Connectivity/
│   │   ├── Purchase/ Push/ Storage/ System/ Intents/
│   │   ├── Intelligence/ Dashboard/ Diagnostics/ Logging/
│   │   └── UI/ Util/ Guides/ Tips/ Rating/ WhatsNew/
│   ├── Models/              # 50+ 数据模型（按 Cloudflare 资源域拆分）
│   ├── Services/            # 47 个 API 服务（Zone/DNS/R2/D1/KV/WAF/Worker…）
│   ├── ViewModels/          # 50+ ObservableObject 视图模型
│   └── Views/               # 24 个功能模块目录
│       ├── Auth/ Dashboard/ DNS/ Zones/ Analytics/
│       ├── DeveloperPlatform/ Workers/ Pages/ Snippets/
│       ├── Storage/ WAF/ ZeroTrust/ Tunnels/ Turnstile/
│       ├── Redirects/ Toolbox/ Settings/ Paywall/
│       └── Push/ Rating/ TestFlight/ WhatsNew/ Guides/ Components/ Main
├── Orange Cloud Watch/           # Watch 小组件/complication
└── Orange Cloud Watch Watch App/ # Watch 独立 App
```

**约定**：三层分离 `Views（UI）→ ViewModels（状态）→ Services（网络）`，Models 纯数据；
`Localizable.xcstrings` + `AppShortcuts.xcstrings` 承载 13 语言；`OrangeCloud-Bridging-Header.h` 桥接 C/ObjC。

### 4.2 `apps/android/` — Kotlin / Compose

```
apps/android/app/src/
├── main/kotlin/jiamin/chen/orangecloud/
│   ├── MainActivity.kt / OrangeCloudApp.kt
│   ├── core/       # auth·crypto·design·di·network·purchase·push·system·update·widget·whatsnew·logging·util
│   ├── data/       # local(Room/DAO) · model · repository
│   └── ui/         # 39 个功能包（zones/dns/workers/storage/waf/analytics/toolbox…）
├── direct/  play/  oss/   # 三种 product flavor 的差异化源码
└── main/res/values-*/     # 13 语言资源
```

**Flavor 策略**：
- `direct` → 官网直装包，签名永久绑死（不可更换）
- `play` → Google Play 上传密钥
- `oss` → 自编译，解锁全部 Pro 功能

**OAuth Client**：`102240eb9095a1965ee11813ef4788cd`（PKCE 公开客户端，与 iOS `OAuthConfig.swift` 同值；OSS 构建可在 `local.properties` 覆盖）。

### 4.3 `apps/harmonyos/` — ArkTS / ArkUI

```
apps/harmonyos/
├── AppScope/          # 应用级配置与资源
├── entry/src/main/ets/
│   ├── core/          # auth·crypto·design·network·purchase·rating·store·system·util·whatsnew
│   ├── models/ services/ viewmodels/
│   ├── views/         # account·auth·dashboard·devhub·guides·pages·paywall·settings·storage·toolbox·turnstile·whatsnew·workers·zones·common
│   ├── widget/        # 卡片（Form）实现
│   ├── entryability/ entrybackupability/ workscheduler/
├── hvigor/            # 构建配置
└── entry/src/ohosTest/ # 测试
```

### 4.4 `apps/web/` — Next.js on Cloudflare Workers

```
apps/web/
├── src/app/
│   ├── [locale]/    # 多语言落地页：buy(bind/recover/refund/reset/success) · guides · privacy · terms · contact
│   ├── admin/       # 管理后台（codes / refund / stats / reset-activations）
│   ├── oauth/       # OAuth 回调中转（自建回调服务）
│   ├── api/         # 路由：checkout·stripe·apple/notifications·asc/webhook·play·redeem·
│   │                #        bind-email·deactivate·refund-request·reset-devices·ranks·geo·guides·indexnow·admin/*
│   ├── sitemap.ts / robots.ts / globals.css
├── src/lib/         # 领域逻辑：stripe·buy·codes·ledger·dashboard·ranks·asc·appstore·
│                    #            play·livestate·notify·indexnow·sibling·site·guides·admin
├── src/components/  # dashboard / guides
├── src/i18n/  src/messages/  # next-intl，13 语言 json
├── migrations/      # D1 SQL 迁移 0001–0011（交易/激活码/退款审核/榜单…）
└── public/          # 图标 / og / 截图(shots: en,ja,zh-Hans,zh-Hant) / .well-known
```

**数据层**：Cloudflare D1，11 个迁移文件覆盖初始化、版本、交易门店报价、App Store 榜单、激活码、Play 平台、IndexNow、订单状态、恢复冷却、退款审核。

### 4.5 `packages/changelog/` — 发布说明单一数据源

| 文件 | 说明 |
| --- | --- |
| `ios.json` (342KB) | iOS 多语发布说明 |
| `android.json` (193KB) | Android 多语发布说明 |
| `harmonyos.json` | 鸿蒙（zh-Hans + en） |
| `index.ts` | 导出入口，供 App codegen 与官网直读 |
| `scripts/gen-{ios,android,harmony}.mjs` | 从 JSON 生成各端源码 |
| `scripts/check.mjs` | 校验一致性 |

---

## 5. 关键架构约定

1. **OAuth 优先，零 Token 粘贴**：Cloudflare OAuth 2.0 + PKCE（公开客户端），按 scope 授权，支持多账号并存；Token 仅存 Keychain（iOS）/ Keystore（Android）。
2. **自定义回调中转**：官方 `o-c.do` 中转与 Client ID 不向第三方构建开放，自编译者需在 `apps/web/` 部署自己的回调服务并在 `local.properties` 覆盖。
3. **开源解锁机制**：iOS 加 `OPENSOURCE_UNLOCKED` 编译条件；Android 用 `oss` flavor。
4. **安全补丁集中管理**：`pnpm-workspace.yaml` 的 `overrides` 精准钉住有 Dependabot 漏洞的间接依赖（undici / form-data / ws / postcss / esbuild / body-parser / js-yaml / sharp / nanoid / brace-expansion），并配置 `allowBuilds`。
5. **四端共享设计语言**：晨昏主题（daybreak / SkyPhase），各端以原生方式重写而非逐屏镜像。

---

## 6. 常用命令（根目录）

```bash
pnpm dev            # 启动 web 开发服务器（turbo --filter=web）
pnpm build          # 全量构建（turbo）
pnpm deploy:web     # 部署官网到 Cloudflare Workers
pnpm preview:web    # OpenNext 本地预览
pnpm lint           # 全量 lint
pnpm changelog:gen  # 生成三端发布说明源码
pnpm changelog:check# 校验发布说明一致性
```

**iOS 构建**：Xcode 26+ 打开 `apps/ios/Orange Cloud/Orange Cloud.xcodeproj`。
**Android 构建**：Gradle（Hilt + KSP），密钥口令文件不入库，缺失时 release 退化为未签名。

---

## 7. 目录速查

| 需求 | 位置 |
| --- | --- |
| 新增一处 Cloudflare API | iOS `Services/` + `Models/`；Android `data/repository` `core/network` |
| 新增一个功能页 | iOS `Views/<模块>/`；Android `ui/<模块>/`；鸿蒙 `views/<模块>/` |
| 修改登录/授权 | iOS `Core/Auth/`；Android `core/auth/`；鸿蒙 `core/auth/`；Web `src/app/oauth/` |
| 改文案/翻译 | `Localizable.xcstrings`(iOS)、`res/values-*`(Android)、`src/messages/*.json`(Web) |
| 改官网后端逻辑 | `apps/web/src/lib/` + `src/app/api/` + `migrations/` |
| 发布说明 | `packages/changelog/*.json` → `pnpm changelog:gen` |
