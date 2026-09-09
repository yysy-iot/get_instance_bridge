# 接力棒：iOS/macOS 原生集成（CocoaPods + SPM）

## 页面/模块
- get_instance_bridge 的 iOS/macOS 原生依赖 `instance_bridge_core` 的集成方式（CocoaPods 与 SPM 双轨）。

## 关键约束
- MethodChannel 名 `"MixInstances"`、路由格式 `method.$typeName.$hashCode.$method` 三端同步，勿改。
- `instance_bridge_core` 是纯原生共享库：CocoaPods trunk + pub.dev hosted（当前 0.0.15，sharedDarwinSource/darwin 结构）。
- get_instance_bridge 依赖：pubspec `instance_bridge_core: ^0.0.15`；ios/macos podspec `s.dependency 'instance_bridge_core', '~> 0.0.15'`。
- **构建体系已切换 SPM 为主轨**（flutter config `enable-swift-package-manager: true`）。example 工程 ios/macos xcodeproj 均为 SPM 集成态（HEAD 已含 FlutterGeneratedPluginSwiftPackage 引用）。
- SPM 变通：ios/ 与 macos/ 下的 `instance_bridge_core` 符号链接（指向 pub-cache 副本的 darwin/instance_bridge_core）是构建必需，已加入根 .gitignore 忽略，勿提交。

## 已完成
- **core 依赖升级至 0.0.15**（含 HashInstance/ObjInstance `@unchecked Sendable` Swift 6 修复），pubspec/podspec/CHANGELOG/lock 已同步。
- **SPM 双平台构建验证通过**：`flutter build ios --debug --no-codesign`、`flutter build macos --debug` 均 `✓ Built`。
- `flutter analyze`（根 + example）无问题；`flutter test`（example）通过。
- iOS/macOS 原生源码已迁移到 SwiftPM 风格目录（`ios/get_instance_bridge/Sources/`）+ 双 `Package.swift`。

## 未完成 / 下一步
- 工作区未提交（迁移态+依赖升级）：提交前需确认暂存范围（含目录迁移 R、Package.swift 新增、podspec/pubspec/CHANGELOG/.gitignore 改动、example 侧 xcodeproj/Podfile 由工具自动改写）。
- iOS/macOS Podfile.lock 仍含 CocoaPods 残留（SPM 迁移提示可 pod deintegrate，暂未执行）。

## 踩过的坑
- **SPM 插件 path 依赖 bug #188646（Flutter 3.47.2 stable 仍在）**：Xcode 按插件真实路径解析 `../instance_bridge_core`，本地 path 插件真实路径下无该兄弟目录 → resolve 失败。变通：在 ios/、macos/ 下建指向 pub-cache core（darwin/instance_bridge_core）的符号链接（已 gitignore）。
- config 曾为 `--no-enable-swift-package-manager`（CocoaPods 主轨），后改回启用：SPM 迁移态工程 + config=false 会导致工具反复注入/回退 xcodeproj、pod 集成异常（只装 Flutter 一个 pod）。**方向已定为 SPM，勿再回退 config**。
- 早期 CocoaPods 构建历史：曾 `git checkout --` 回退 xcodeproj 保持 CocoaPods 态，现已被 SPM 路线取代。
- core 版本注意：方案文档中旧数字（0.0.14）无效，实际发布为 0.0.15（trunk + pub.dev 均已确认）。
- `pod install` 需 `export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8`（Ruby 4.0.6 + CocoaPods 1.17.0 `Encoding::CompatibilityError`）。
