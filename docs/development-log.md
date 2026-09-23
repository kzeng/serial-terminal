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

### CI 静态分析修复

- 移除未使用的 `_reader` 状态字段。
- 保留读取流订阅作为串口接收生命周期的管理对象。

### Widget 测试修复

- Widget 测试不再在启动时加载真实串口动态库。
- 串口枚举增加异常处理，缺少原生库时显示错误而不是让应用崩溃。
- 修复 Widget 销毁时释放串口资源仍调用 `setState` 的生命周期错误。

## 2026-09-23：版本、串口配置与桌面布局

- 版本号回到 `0.0.1+1`，产品版本号采用 `x.x.x` 格式。
- 补齐数据位、校验位、停止位、流控和发送结束符配置。
- 主界面改为左右两栏：左侧垂直连接配置，右侧通信日志和发送区。
- Windows 中文字体优先使用 `Microsoft YaHei UI`，并配置中文和英文字体回退。

## 2026-09-23：Actions 静态分析修复

- 移除不必要的字符串插值大括号。
- 使用 `withValues(alpha: ...)` 替换已弃用的 `withOpacity`。
- 拆分日志区域 Widget，修复括号结构导致的 Dart 语法错误。
- 将连接参数改为左栏单列布局，修复窄窗口下下拉框文字溢出。
