# HXProject 全套重构计划

## 一、现状分析

### 当前问题
| 问题 | 详情 |
|------|------|
| **目录混乱** | `ObjectCBase/` + `UIKit/` 两大类，内部 KVC/KVO/Crash/Runtime/通知/MVVM 全平铺，无层次 |
| **首页扁平** | `HXHomeViewController` 是所有知识点的 TableView，无分组、无搜索、无副标题 |
| **双 TabBar 冗余** | `HXTabBarController`(简单) 和 `HXMainContainer`(Lottie+JSON) 两套，`SceneDelegate` 先设一个又覆盖为另一个 |
| **4 个 Tab 全是同一个 VC** | `HXMainContainer.setupViewControllers` 里 4 个 tab 都创建 `HXHomeViewController` |
| **数据源硬编码** | 每个 VC 在 `.m` 里手写 `@[@{@"title":@"", @"class":@""}]` 字典数组 |
| **导航用字符串反射** | `NSClassFromString([item objectForKey:@"class"])` — 类名改了就 crash |
| **Vender 内嵌 AFNetworking 源码** | 应该走 CocoaPods |
| **空目录** | `cc/` 目录为空，应删除 |
| **`HXVenderViewController` 是 NSObject** | 不是 UIViewController，未使用 |

### 现有 TabBar 结构（来自 tabs.json）
- 首页 → HXHomeViewController (ObjectC 知识点)
- 课程 → HXHomeViewController (同上，重复)
- 广场 → HXHomeViewController (同上，重复)
- 我的 → HXHomeViewController (同上，重复)

---

## 二、新目录结构

```
HXProject/
├── AppDelegate/                    ← 不变
├── Define/                         ← 不变 (宏定义、颜色、字体、通知常量)
├── Base/                           ← 基础 UI 层
│   ├── NavigationController/       ← 不变
│   ├── TabBarController/           ← 保留 HXTabBarController，HXMainContainer 不再创建 tabs
│   ├── TabbarManager/              ← 保留 HXTabConfigureManager、Lottie、YYCustomTabBar
│   └── ViewController/            ← 保留 PBViewController (基类)
├── Topics/                         ★ 新增：主题管理层
│   ├── Model/
│   │   ├── HXTopicModel.h/m        ← 单个知识点模型
│   │   └── HXSectionModel.h/m      ← 章节分组模型
│   ├── Manager/
│   │   └── HXTopicDataManager.h/m  ← 数据加载/搜索/收藏
│   ├── Resources/
│   │   └── topic_config.json       ← ★ 唯一数据源
│   └── HXHomeViewController.h/m    ← 重写：分组+搜索首页
├── Modules/                        ★ 重命名+迁移：所有知识点模块
│   ├── Memory/
│   │   └── AutoReleasePool/        ← 从 ObjectCBase/AutoReleasePool 移入
│   ├── KVC/                        ← 从 ObjectCBase/KVC 移入
│   │   └── Model/
│   ├── KVO/                        ← 从 ObjectCBase/KVO 移入
│   │   └── KVOCrash/
│   ├── Runtime/                    ← 从 ObjectCBase/RunTime 移入
│   ├── Crash/                      ← 从 ObjectCBase/Crash 移入
│   ├── NotificationCenter/         ← 从 ObjectCBase/NotificationCenter 移入
│   │   └── CustomNotificationCenter/
│   ├── MVVM/                       ← 从 ObjectCBase/MVVM 移入
│   │   ├── Model/
│   │   ├── ViewController/
│   │   └── ViewModel/
│   ├── Network/                    ← 从 ObjectCBase/NetWork 移入
│   ├── HitTest/                    ← 从 UIKit/事件传递 移入
│   ├── Rendering/                  ← 从 UIKit/离屏渲染 移入
│   ├── ViewControllerLifeCycle/    ← 从 UIKit/ViewController生命周期 移入
│   │   └── PushPop/
│   └── Defender/                   ← 从 ObjectCBase/YSCDefender + ZYBSwizzle 合并移入
├── Vender/                         ← 精简：删除 AFNetworking 源码（走 Pod）
│   └── (清空或保留空壳)
├── ZYBSwizzle/                     ← 不变
├── ViewController.h/m              ← ★ 重写：作为"首页"Tab 的根 VC
└── Supporting Files/               ← 不变
```

### 删除项
- `cc/` 空目录
- `HXVenderViewController.h/m` (无用的 NSObject)
- `Vender/AFNetworking/` 全部源码（由 Pods 管理）
- `ObjectCBase/` 整个目录（迁移到 Modules/）
- `UIKit/` 整个目录（迁移到 Modules/）
- `HXUIHomeViewController.h/m`（合并入新首页分组）

---

## 三、数据层设计

### topic_config.json（项目唯一数据源）

```json
{
  "version": "1.0",
  "sections": [
    {
      "id": "lang_runtime",
      "title": "语言 & 底层",
      "icon": "📱",
      "subtitle": "Objective-C 运行时、内存管理、Crash 防护",
      "topics": [
        {
          "id": "memory",
          "title": "内存管理",
          "icon": "🧠",
          "subtitle": "AutoReleasePool 原理与 RunLoop 关联",
          "vcClass": "AutoReleaseViewController"
        },
        {
          "id": "kvc",
          "title": "KVC 键值编码",
          "icon": "🔑",
          "subtitle": "KVC 原理 / Crash 场景 / 防崩溃",
          "vcClass": "KVCViewController"
        },
        {
          "id": "kvocrash",
          "title": "KVC Crash 测试",
          "icon": "💣",
          "subtitle": "KVC 常见 Crash 场景复现与防御",
          "vcClass": "TestKVCCrashVC"
        },
        {
          "id": "kvo",
          "title": "KVO 键值观察",
          "icon": "👁️",
          "subtitle": "KVO 原理 / Crash 场景 / 防崩溃",
          "vcClass": "KVOViewController"
        },
        {
          "id": "kvocrash",
          "title": "KVO Crash 测试",
          "icon": "💣",
          "subtitle": "KVO 常见 Crash 场景复现与防御",
          "vcClass": "TestKVOCrashVC"
        },
        {
          "id": "runtime",
          "title": "Runtime 运行时",
          "icon": "⚙️",
          "subtitle": "消息转发 / Method Swizzling / 动态添加方法",
          "vcClass": "HXRunTimeViewController"
        },
        {
          "id": "crash",
          "title": "Crash 分析",
          "icon": "💥",
          "subtitle": "常见 Crash 类型分析与定位",
          "vcClass": "HXCrashViewController"
        },
        {
          "id": "notification",
          "title": "通知中心",
          "icon": "🔔",
          "subtitle": "NSNotification / 自定义通知中心实现",
          "vcClass": "HXNotificationViewController"
        },
        {
          "id": "custom_notification",
          "title": "自定义通知中心",
          "icon": "🏗️",
          "subtitle": "手写实现一套线程安全的通知中心",
          "vcClass": "CustomNotificationCenterViewController"
        },
        {
          "id": "mvvm",
          "title": "MVVM 架构",
          "icon": "🏛️",
          "subtitle": "Model-View-ViewModel 实践",
          "vcClass": "HXMVVMViewController"
        },
        {
          "id": "network",
          "title": "网络请求",
          "icon": "📡",
          "subtitle": "NSURLSession / AFNetworking 实战",
          "vcClass": "HXNetWorkViewController"
        }
      ]
    },
    {
      "id": "ui_rendering",
      "title": "UIKit & 渲染",
      "icon": "🎨",
      "subtitle": "事件传递、离屏渲染、生命周期",
      "topics": [
        {
          "id": "hittest",
          "title": "事件传递链",
          "icon": "✋",
          "subtitle": "Hit-Test 机制 / 响应链 / 手势冲突",
          "vcClass": "HXEventTestViewController"
        },
        {
          "id": "offscreen",
          "title": "离屏渲染",
          "icon": "🖥️",
          "subtitle": "离屏渲染原理与性能优化",
          "vcClass": "OffScreenViewController"
        },
        {
          "id": "lifecycle",
          "title": "ViewController 生命周期",
          "icon": "🔄",
          "subtitle": "完整生命周期链路 / Push-Pop / Present-Dismiss",
          "vcClass": "LifeCycleViewController"
        }
      ]
    },
    {
      "id": "tools",
      "title": "网络 & 工具",
      "icon": "🛠",
      "subtitle": "AFNetworking / JSONModel / 安全防护",
      "topics": [
        {
          "id": "afnetworking",
          "title": "AFNetworking",
          "icon": "🌐",
          "subtitle": "网络请求封装与安全策略",
          "vcClass": "HXVenderViewController"
        },
        {
          "id": "defender",
          "title": "安全防护 (Defender)",
          "icon": "🛡️",
          "subtitle": "KVC/KVO/Selector 防崩溃防护",
          "vcClass": "TestUnrecognizedSelVC"
        }
      ]
    }
  ]
}
```

### HXTopicModel

```objc
@interface HXTopicModel : NSObject
@property (nonatomic, copy) NSString *topicId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *vcClass;
@property (nonatomic, assign) BOOL isFavorite;
@end
```

### HXSectionModel

```objc
@interface HXSectionModel : NSObject
@property (nonatomic, copy) NSString *sectionId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) NSArray<HXTopicModel *> *topics;
@end
```

### HXTopicDataManager（单例）

```objc
@interface HXTopicDataManager : NSObject
+ (instancetype)sharedManager;
- (NSArray<HXSectionModel *> *)allSections;
- (NSArray<HXTopicModel *> *)searchTopics:(NSString *)keyword;
- (void)toggleFavorite:(NSString *)topicId;
- (NSArray<HXTopicModel *> *)favoriteTopics;
@end
```

---

## 四、页面设计

### 首页 (HXHomeViewController)

```
┌─────────────────────────────────────┐
│  🔍 搜索知识点...                    │  UISearchBar
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────────┐│
│  │ 📱 语言 & 底层    Objective-C    ││  Section Header (含 icon + subtitle)
│  │ 运行时、内存管理、Crash 防护      ││
│  ├─────────────────────────────────┤│
│  │ 🧠 内存管理                     ││  Topic Card Cell
│  │ AutoReleasePool 原理与 RunLoop 关联││
│  ├─────────────────────────────────┤│
│  │ 🔑 KVC 键值编码                  ││
│  │ KVC 原理 / Crash 场景 / 防崩溃    ││
│  ├─────────────────────────────────┤│
│  │ ...                             ││
│  └─────────────────────────────────┘│
│                                     │
│  ┌─────────────────────────────────┐│
│  │ 🎨 UIKit & 渲染   事件、渲染     ││
│  │ ...                             ││
│  └─────────────────────────────────┘│
│                                     │
│  ┌─────────────────────────────────┐│
│  │ 🛠 网络 & 工具   AFN / 防护     ││
│  │ ...                             ││
│  └─────────────────────────────────┘│
└─────────────────────────────────────┘
```

### TabBar 改造（tabs.json 改为 3 个 Tab）

| Tab | 标题 | 内容 |
|-----|------|------|
| 📱 知识 | 首页（HXHomeViewController） | 所有知识点分组 |
| 🧮 算法 | HXLeetCode 首页 | HXLeetCode 库中的算法 Demo |
| ⚙️ 工具 | HXVenderViewController (重写) | 第三方库集成示例 |

---

## 五、实施步骤

### Step 0: 清理 cc/ 空目录

### Step 1: 创建 Topics/ 数据层
- 新建 `Topics/Model/HXTopicModel.h/m`
- 新建 `Topics/Model/HXSectionModel.h/m`
- 新建 `Topics/Manager/HXTopicDataManager.h/m`
- 新建 `Topics/Resources/topic_config.json`

### Step 2: 创建 Modules/ 目录结构
- 建立所有子目录

### Step 3: 迁移源文件
- `ObjectCBase/AutoReleasePool/*` → `Modules/Memory/AutoReleasePool/`
- `ObjectCBase/KVC/*` → `Modules/KVC/`
- `ObjectCBase/KVO/*` → `Modules/KVO/`
- `ObjectCBase/RunTime/*` → `Modules/Runtime/`
- `ObjectCBase/Crash/*` → `Modules/Crash/`
- `ObjectCBase/NotificationCenter/*` → `Modules/NotificationCenter/`
- `ObjectCBase/MVVM/*` → `Modules/MVVM/`
- `ObjectCBase/NetWork/*` → `Modules/Network/`
- `UIKit/事件传递/*` → `Modules/HitTest/`
- `UIKit/离屏渲染/*` → `Modules/Rendering/`
- `UIKit/ViewController生命周期/*` → `Modules/ViewControllerLifeCycle/`
- `ObjectCBase/YSCDefender/*` + `ZYBSwizzle/*` → `Modules/Defender/`
- 删除 `ObjectCBase/HXHomeViewController.*` (旧的)
- 删除 `UIKit/HXUIHomeViewController.*` (旧的)
- 删除 `Vender/AFNetworking/` (Pod 管理)

### Step 4: 更新 Xcode 项目文件 (.pbxproj)
- 更新所有文件引用路径
- 删除旧目录引用，添加新目录引用

### Step 5: 重写首页 (Topics/HXHomeViewController)
- 基于新数据模型的分组 TableView
- UISearchController 搜索
- 支持收藏切换

### Step 6: 更新 TabBar
- 修改 `tabs.json` → 3 个 tab
- 修改 `HXMainContainer` 让不同 tab 加载不同 VC

### Step 7: 清理 Podfile
- 确认 AFNetworking 由 Pods 管理，删除源码

### Step 8: 编译验证
- pod install
- 确保编译通过，功能正常

---

## 六、风险与注意事项

1. **Xcode .pbxproj 手动编辑风险** — 涉及大量文件路径变更，建议备份
2. **#import 路径变更** — 迁移后需批量更新 import 语句
3. **tabs.json 格式** — HXMainContainer 依赖 tabs.json 结构驱动 TabBar
4. **原 ViewController.m** — 目前是 SceneDelegate 的初始 root，但实际被 HXMainContainer 覆盖，保留或改入口
5. **git 状态** — 已完成一次权限修复 commit，最好先 push 再做重构