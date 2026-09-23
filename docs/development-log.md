# 开发记录

## 2026-09-23

### 初始化

- 确认项目目标为 Flutter Windows 串口调试助手。
- 确认本机使用 Visual Studio Code 编码，不安装 Flutter SDK。
- 确认 GitHub Actions 使用 Windows runner 构建。
- 初始化 Flutter 应用骨架和 Material 3 基础界面。
- 采用 `flutter_libserialport` 作为串口后端，支持 Windows。
- 首版实现串口刷新、连接/断开、波特率、文本/HEX 收发、时间戳、自动滚动和清空。

### 尚未验证

- 本机没有 Flutter SDK，当前无法本地执行 `flutter analyze`、`flutter test` 或 `flutter build windows`。
- 需要 GitHub Actions 首次运行后确认 Flutter 包 API、Windows 原生库打包和真实串口行为。
