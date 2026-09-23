# Serial Terminal

Flutter Windows 串口调试助手。

## 开发方式

- 本机编辑器：Visual Studio Code
- 本机 Flutter SDK：不安装
- 本机运行/构建：不执行
- CI：GitHub Actions Windows runner
- 串口后端：`flutter_libserialport`

## 文档

- [产品需求](docs/product-requirements.md)
- [开发记录](docs/development-log.md)
- [变更记录](docs/changelog.md)
- [MIT License](LICENSE)
- [代码签名策略](docs/code-signing-policy.md)

## VS Code 插件

必须安装：

- Dart Code 的 **Dart** 扩展：语法高亮、格式化和基础 Dart 支持
- Dart Code 的 **Flutter** 扩展：Flutter 项目识别、Widget 代码辅助和 CI 命令提示

推荐安装：

- **GitLens**：查看提交、分支和文件历史
- **YAML**：校验 GitHub Actions YAML
- **Error Lens**：将编辑器诊断直接显示在代码行旁
- **Markdown All in One**：维护项目文档

由于本机不安装 Flutter SDK，Dart/Flutter 扩展的完整分析、调试和热重载能力不可用；这些检查由 GitHub Actions 执行。

## CI

提交或推送后，Actions 会在 Windows runner 上固定版本安装 Flutter，执行依赖安装、分析、测试和 Windows Release 构建，并上传发布目录。

## 代码签名

项目采用 MIT License。Windows 发布产物计划通过 SignPath Foundation 进行
Authenticode 签名；签名流程和验证规则见[代码签名策略](docs/code-signing-policy.md)。
