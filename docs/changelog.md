# 变更记录

## Unreleased

- 添加 MIT License 和公开代码签名策略。
- 准备 SignPath Foundation GitHub Actions 签名流程；获得项目批准并配置变量后，主分支构建会自动提交 Windows 产物签名。

## 0.0.4

- 增大下拉列表选项高度，改善 Windows 桌面鼠标操作体验。
- 使用 ASCII-only C++ 宽字符 Unicode 转义生成原生窗口标题，修复标题栏图标后的中文乱码。

## 0.0.3

- 修复 Windows 原生窗口标题因 C++ 源文件编码导致的中文乱码。
- GitHub Actions 使用 C++ Unicode 转义写入窗口标题，避免构建环境编码差异。

## 0.0.2

- 应用标题统一为“串口调试助手”。
- 增加底部状态栏，显示版本、连接状态和最新运行消息。

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
- 修复 Flutter analyze 报告的字符串插值、透明度 API 和日志区域语法问题。
- 修复窄窗口下串口参数下拉框的 RenderFlex 溢出。
