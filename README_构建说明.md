# BabyTrack iOS App — 构建说明

## 项目结构

```
BabyTrack_Project/
├── BabyTrack.xcodeproj/    # Xcode 项目文件
└── BabyTrack/              # 源代码
    ├── BabyTrackApp.swift  # 应用入口
    ├── Models.swift        # 数据模型（SwiftData）
    ├── Helpers.swift       # 工具类、颜色、复用组件
    ├── RootView.swift      # 根视图（Tab 导航）
    ├── SetupView.swift     # 首次设置
    ├── HomeView.swift      # 首页仪表盘
    ├── FeedingView.swift   # 喂养记录
    ├── BowelView.swift     # 排便记录
    ├── SupplementView.swift# 补充剂记录
    ├── GrowthView.swift    # 生长曲线（含 Charts）
    ├── ReportView.swift    # 数据报告 + 导出
    ├── SettingsView.swift  # 设置页
    └── Assets.xcassets/    # 图标与颜色资源
```

## 环境要求

| 要求 | 版本 |
|------|------|
| macOS | 14.0 (Sonoma) 或更高 |
| Xcode | 15.0 或更高 |
| iOS 目标 | 17.0+ |
| Swift | 5.9 |

## 构建步骤

### 方式一：Xcode 模拟器运行（无需开发者账号）

1. 解压 `BabyTrack_iOS_源码.zip`
2. 双击打开 `BabyTrack.xcodeproj`
3. 在顶部选择目标设备（如 **iPhone 15 Simulator**）
4. 点击 ▶ 运行按钮（或 `Cmd + R`）

### 方式二：真机安装（需要 Apple 开发者账号）

1. 打开项目后，点击左侧项目导航器中的 **BabyTrack**
2. 选择 **Signing & Capabilities**
3. 勾选 **Automatically manage signing**
4. 在 **Team** 下拉框选择你的 Apple ID（免费账号可用于个人设备）
5. 连接 iPhone，选择真机设备
6. 点击 ▶ 运行，手机上弹出信任提示后允许即可安装

### 方式三：生成 .ipa 安装包（需要付费开发者账号 $99/年）

```bash
# Archive
xcodebuild -project BabyTrack.xcodeproj \
           -scheme BabyTrack \
           -configuration Release \
           -archivePath ./BabyTrack.xcarchive \
           archive

# Export IPA
xcodebuild -exportArchive \
           -archivePath ./BabyTrack.xcarchive \
           -exportOptionsPlist ExportOptions.plist \
           -exportPath ./output
```

## 功能说明

- **首页**：宝宝信息卡、今日记录统计、血丝预警横幅
- **喂养记录**：支持母乳/配方奶/混合，记录新辅食及反应
- **排便记录**：颜色、性状、血丝、黏液全记录
- **补充剂**：维生素D、益生菌等，预设常用补充剂
- **生长曲线**：体重/身高/头围折线图（Swift Charts）
- **数据报告**：自定义日期区间，血丝日期汇总，新食物列表，文字导出分享
