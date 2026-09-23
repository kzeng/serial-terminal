# 变更记录

## Unreleased

### Changed

- 版本号起始为 `0.0.1`。
- 主界面调整为左右两栏桌面布局。
- Windows 中文字体增加 `Microsoft YaHei UI` 优先和字体回退。
- 左侧配置区改为垂直布局。

### Added

- 创建 Flutter Windows 串口调试助手项目。
- 增加串口枚举、连接、断开和波特率选择。
- 增加文本/HEX 接收和发送模式。
- 增加时间戳、自动滚动、清空日志和发送区。
- 增加 VS Code 开发插件建议。
- 增加 GitHub Actions Windows 构建流程。

### Fixed

- 修复 `flutter analyze` 报告的未使用 `_reader` 字段警告。
- 修复 Widget 测试加载 `serialport.dll` 导致失败的问题。
- 增加串口枚举失败时的错误提示。
- 修复测试销毁 Widget 时的 `setState` 生命周期断言。
- 增加数据位、校验位、停止位、流控和发送结束符配置。
