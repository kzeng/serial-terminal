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

## 2026-09-23：标题与状态栏

- 应用标题和 Windows 窗口标题统一为“串口调试助手”。
- 底部新增状态栏，显示连接状态、最新运行/错误消息和版本号。
- 按补丁版本规则将版本更新为 `0.0.2+2`，准备发布新构建。
### 2026-09-23

- 修复 Windows 窗口标题乱码：Actions 不再把中文直接写入生成的 C++ 源文件，改用 C++ Unicode 转义序列。
- 版本号更新为 `0.0.3`，并同步更新窗口标题回归测试。
### 2026-09-23（补充）

- 下拉控件统一使用 48px 选项高度，并限制菜单最大高度为 420px。
- 原生窗口标题继续采用 ASCII-only 的 C++ 宽字符 Unicode 转义，避免中文源文件编码影响标题栏显示。
- 版本号更新为 `0.0.4`。
### 2026-09-23（开源与签名准备）

- 根据确认采用 MIT License，新增根目录 `LICENSE`。
- 新增 `docs/code-signing-policy.md`，说明签名范围、审核规则、秘密管理和用户验证方式。
- GitHub Actions 增加 SignPath Foundation 官方 Action 的签名骨架：先上传未签名产物，签名完成后替换构建目录，再上传最终产物。
- SignPath 参数仅在 `main` 分支且配置了 `SIGNPATH_ORGANIZATION_ID` 时启用；未完成 SignPath 审批或配置时仍保留普通未签名构建。
### 2026-09-23（签名策略决策）

- SignPath Foundation 因项目知名度不足暂未通过申请。
- 当前暂不启用 Windows 代码签名，继续通过 GitHub Releases 发布未签名 ZIP。
- 保留 SignPath GitHub Actions 集成；未来获得批准或采用其他签名服务后，仅需配置对应参数即可启用。
