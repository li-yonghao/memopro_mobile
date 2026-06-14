# MemoPro Mobile - iOS & Android 备忘录应用

基于 **Flutter** 构建，一套代码同时运行在 iOS 和 Android 上。

---

## 功能特性

- ✅ 亮色/暗色主题切换（Material Design 3）
- ✅ 自定义备忘录标题 + 内容编辑
- ✅ 时间提醒闹钟（本地通知，即使 App 在后台也能收到）
- ✅ 备忘录置顶 / 滑动删除（带撤销）
- ✅ 全文搜索
- ✅ iOS & Android 原生通知
- ✅ 数据本地持久化存储

---

## 项目结构

```
memopro_mobile/
├── lib/
│   ├── main.dart                 # 应用入口
│   ├── models/
│   │   └── memo.dart             # 备忘录数据模型
│   ├── screens/
│   │   ├── home_screen.dart      # 主页（列表+搜索+删除）
│   │   └── editor_screen.dart    # 编辑器（标题+内容+提醒）
│   ├── services/
│   │   ├── memo_service.dart     # 数据存储服务
│   │   └── reminder_service.dart # 提醒通知服务
│   └── theme/
│       └── app_theme.dart        # 亮/暗主题定义
├── android/                      # Android 原生配置
├── ios/                          # iOS 原生配置
├── .github/workflows/build.yml   # CI/CD 自动构建
└── pubspec.yaml                  # 依赖配置
```

---

## 构建方式

### 方式一：GitHub Actions 云端构建（推荐）

1. 将本项目推送到你的 GitHub 仓库
2. GitHub Actions 会自动触发构建
3. 在 Actions 页面下载 `memopro-android-apks`（Android）和 `memopro-ios-ipa`（iOS）

### 方式二：本地构建

**前置条件：**
- Flutter SDK 3.22+
- Android Studio + Android SDK
- Xcode（仅 iOS，需要 macOS）

```bash
# 安装依赖
cd memopro_mobile
flutter pub get

# 构建 Android APK
flutter build apk --release --split-per-abi
# APK 位置：build/app/outputs/flutter-apk/

# 构建 iOS（需要 macOS + Xcode）
flutter build ios --release
```

### 安装到手机

**Android：**
- 直接将 `.apk` 文件传到手机，点击安装
- arm64-v8a：适用于绝大多数现代手机
- armeabi-v7a：适用于较老的 32 位设备
- x86_64：适用于模拟器

**iOS：**
- 需要通过 Xcode 签名或用企业证书分发
- 也可通过 TestFlight 分发

---

## 依赖包

| 包名 | 用途 |
|------|------|
| `shared_preferences` | 本地 JSON 数据存储 |
| `flutter_local_notifications` | 系统通知（闹钟提醒） |
| `intl` | 日期格式化 |
| `uuid` | 唯一 ID 生成 |
| `timezone` | 时区处理 |

---

## 商业化

MemoPro 代码完全自研，无许可证限制，可自由商用。

---

## 版本

v1.0.0 — 首发版本，iOS & Android 双端适配
