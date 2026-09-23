import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

const appVersion = '0.0.3';

void main() => runApp(const SerialTerminalApp());

class SerialTerminalApp extends StatelessWidget {
  const SerialTerminalApp({super.key, this.loadPorts = true});

  final bool loadPorts;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF008577);
    final scheme = ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.light);
    return MaterialApp(
      title: '串口调试助手',
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        fontFamily: 'Microsoft YaHei UI',
        fontFamilyFallback: const ['Microsoft YaHei', 'Segoe UI'],
        inputDecorationTheme: const InputDecorationTheme(
          isDense: true,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
      home: SerialTerminalPage(loadPorts: loadPorts),
    );
  }
}

class SerialTerminalPage extends StatefulWidget {
  const SerialTerminalPage({super.key, this.loadPorts = true});

  final bool loadPorts;

  @override
  State<SerialTerminalPage> createState() => _SerialTerminalPageState();
}

class _SerialTerminalPageState extends State<SerialTerminalPage> {
  final _sendController = TextEditingController();
  final _logController = ScrollController();
  SerialPort? _port;
  StreamSubscription<Uint8List>? _subscription;
  List<String> _ports = const [];
  String? _selectedPort;
  int _baudRate = 115200;
  int _dataBits = 8;
  int _parity = SerialPortParity.none;
  int _stopBits = 1;
  int _flowControl = SerialPortFlowControl.none;
  int _lineEnding = 0;
  bool _connected = false;
  bool _hexReceive = false;
  bool _hexSend = false;
  bool _showTimestamp = true;
  bool _autoScroll = true;
  String _statusMessage = '就绪';
  final List<String> _lines = [];

  bool get _canEditConnection => !_connected;

  @override
  void initState() {
    super.initState();
    if (widget.loadPorts) _refreshPorts();
  }

  @override
  void dispose() {
    _disconnect(updateState: false);
    _sendController.dispose();
    _logController.dispose();
    super.dispose();
  }

  void _refreshPorts() {
    try {
      final ports = SerialPort.availablePorts;
      setState(() {
        _ports = ports;
        _selectedPort = _ports.contains(_selectedPort)
            ? _selectedPort
            : (_ports.isEmpty ? null : _ports.first);
      });
    } catch (error) {
      _append('枚举串口失败: $error');
    }
  }

  void _connect() {
    final name = _selectedPort;
    if (name == null) return;
    final port = SerialPort(name);
    try {
      if (!port.openReadWrite()) {
        _append('打开 $name 失败: ${SerialPort.lastError}');
        port.dispose();
        return;
      }
      final config = port.config;
      try {
        config.baudRate = _baudRate;
        config.bits = _dataBits;
        config.parity = _parity;
        config.stopBits = _stopBits;
        config.setFlowControl(_flowControl);
        port.config = config;
      } finally {
        config.dispose();
      }
      final reader = SerialPortReader(port);
      _subscription = reader.stream.listen(_receive, onError: (Object error) => _append('接收错误: $error'));
      setState(() {
        _port = port;
        _connected = true;
      });
      _append('已连接 $name · $_baudRate $_dataBits-$_parityName$_stopBits');
    } catch (error) {
      port.close();
      port.dispose();
      _append('连接失败: $error');
    }
  }

  String get _parityName {
    switch (_parity) {
      case SerialPortParity.even:
        return 'E';
      case SerialPortParity.odd:
        return 'O';
      case SerialPortParity.mark:
        return 'M';
      case SerialPortParity.space:
        return 'S';
      default:
        return 'N';
    }
  }

  void _disconnect({bool updateState = true}) {
    _subscription?.cancel();
    _subscription = null;
    _port?.close();
    _port?.dispose();
    _port = null;
    if (updateState && mounted) {
      setState(() {
        _connected = false;
        _statusMessage = '已断开连接';
      });
    }
  }

  void _receive(Uint8List data) {
    final value = _hexReceive
        ? data.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ')
        : utf8.decode(data, allowMalformed: true);
    _append('RX  $value');
  }

  void _send() {
    final port = _port;
    if (port == null || !_connected) return;
    final text = _sendController.text;
    if (text.isEmpty) return;
    try {
      final Uint8List data;
      if (_hexSend) {
        final bytes = text
            .split(RegExp(r'[ ,]+'))
            .where((item) => item.isNotEmpty)
            .map((item) => int.parse(item, radix: 16))
            .toList();
        data = Uint8List.fromList(bytes);
      } else {
        data = Uint8List.fromList(utf8.encode(text + _lineEndingText));
      }
      port.write(data);
      _append('TX  ${_hexSend ? text : text + _lineEndingText}');
    } catch (error) {
      _append('发送失败: $error');
    }
  }

  String get _lineEndingText {
    switch (_lineEnding) {
      case 1:
        return '\r';
      case 2:
        return '\n';
      case 3:
        return '\r\n';
      default:
        return '';
    }
  }

  void _append(String line) {
    if (!mounted) return;
    final prefix = _showTimestamp ? '${DateTime.now().toLocal().toIso8601String()}  ' : '';
    setState(() {
      _lines.add('$prefix$line');
      _statusMessage = line;
    });
    if (_autoScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_logController.hasClients) {
          _logController.jumpTo(_logController.position.maxScrollExtent);
        }
      });
    }
  }

  Widget _select<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: items,
      onChanged: _canEditConnection ? onChanged : null,
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Row(children: [Icon(Icons.cable, size: 22), SizedBox(width: 10), Text('串口调试助手')]),
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 300, child: _buildConnectionPanel(colors)),
                const VerticalDivider(width: 1),
                Expanded(child: _buildTerminalPanel(colors)),
              ],
            ),
          ),
          _buildStatusBar(colors),
        ],
      ),
    );
  }

  Widget _buildStatusBar(ColorScheme colors) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 9, color: _connected ? colors.primary : colors.outline),
          const SizedBox(width: 7),
          Text(_connected ? '已连接' : '未连接', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 18),
          Container(width: 1, height: 16, color: colors.outlineVariant),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              _statusMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
            ),
          ),
          const SizedBox(width: 16),
          Text('版本 $appVersion', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildConnectionPanel(ColorScheme colors) {
    return Material(
      color: colors.surfaceContainerLowest,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('连接配置', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('设置通信参数后打开串口', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
          const SizedBox(height: 20),
          _sectionTitle('端口'),
          Row(children: [
            Expanded(child: _select<String>(label: '串口', value: _selectedPort, items: _ports.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(), onChanged: (value) => setState(() => _selectedPort = value))),
            const SizedBox(width: 8),
            IconButton(onPressed: _refreshPorts, tooltip: '刷新串口', icon: const Icon(Icons.refresh)),
          ]),
          const SizedBox(height: 12),
          _sectionTitle('通信参数'),
          _select<int>(label: '波特率', value: _baudRate, items: [1200, 2400, 4800, 9600, 19200, 38400, 57600, 115200, 230400].map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(), onChanged: (v) => setState(() => _baudRate = v!)),
          const SizedBox(height: 10),
          _select<int>(label: '数据位', value: _dataBits, items: [5, 6, 7, 8].map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(), onChanged: (v) => setState(() => _dataBits = v!)),
          const SizedBox(height: 10),
          _select<int>(label: '校验位', value: _parity, items: const [DropdownMenuItem(value: SerialPortParity.none, child: Text('无')), DropdownMenuItem(value: SerialPortParity.even, child: Text('偶校验')), DropdownMenuItem(value: SerialPortParity.odd, child: Text('奇校验')), DropdownMenuItem(value: SerialPortParity.mark, child: Text('Mark')), DropdownMenuItem(value: SerialPortParity.space, child: Text('Space'))], onChanged: (v) => setState(() => _parity = v!)),
          const SizedBox(height: 10),
          _select<int>(label: '停止位', value: _stopBits, items: const [DropdownMenuItem(value: 1, child: Text('1')), DropdownMenuItem(value: 2, child: Text('2'))], onChanged: (v) => setState(() => _stopBits = v!)),
          const SizedBox(height: 10),
          _select<int>(label: '流控', value: _flowControl, items: const [DropdownMenuItem(value: SerialPortFlowControl.none, child: Text('无')), DropdownMenuItem(value: SerialPortFlowControl.rtsCts, child: Text('RTS/CTS')), DropdownMenuItem(value: SerialPortFlowControl.dtrDsr, child: Text('DTR/DSR')), DropdownMenuItem(value: SerialPortFlowControl.xonXoff, child: Text('XON/XOFF'))], onChanged: (v) => setState(() => _flowControl = v!)),
          const SizedBox(height: 20),
          FilledButton.icon(onPressed: _selectedPort == null ? null : (_connected ? _disconnect : _connect), icon: Icon(_connected ? Icons.link_off : Icons.link), label: Text(_connected ? '断开连接' : '打开串口'), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14))),
          const SizedBox(height: 20),
          _sectionTitle('显示与发送'),
          _select<int>(label: '发送结束符', value: _lineEnding, items: const [DropdownMenuItem(value: 0, child: Text('无')), DropdownMenuItem(value: 1, child: Text('CR  \\r')), DropdownMenuItem(value: 2, child: Text('LF  \\n')), DropdownMenuItem(value: 3, child: Text('CRLF  \\r\\n'))], onChanged: (v) => setState(() => _lineEnding = v!)),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('接收 HEX'), value: _hexReceive, onChanged: (v) => setState(() => _hexReceive = v)),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('显示时间戳'), value: _showTimestamp, onChanged: (v) => setState(() => _showTimestamp = v)),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('自动滚动'), value: _autoScroll, onChanged: (v) => setState(() => _autoScroll = v)),
        ]),
      ),
    );
  }

  Widget _buildTerminalPanel(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Text('通信日志', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const Spacer(),
          Text('${_lines.length} 条', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
          const SizedBox(width: 12),
          OutlinedButton.icon(onPressed: () => setState(_lines.clear), icon: const Icon(Icons.delete_outline, size: 18), label: const Text('清空')),
        ]),
        const SizedBox(height: 10),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF172126),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(14),
            child: _lines.isEmpty
                ? Center(
                    child: Text(
                      '暂无数据\n连接串口后，接收内容会显示在这里',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        height: 1.8,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _logController,
                    itemCount: _lines.length,
                    itemBuilder: (_, index) => SelectableText(
                      _lines[index],
                      style: const TextStyle(
                        color: Color(0xFFD6E6E3),
                        fontFamily: 'Cascadia Mono',
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: TextField(controller: _sendController, minLines: 1, maxLines: 4, decoration: const InputDecoration(labelText: '发送数据', hintText: '输入文本或 HEX 字节，例如：01 03 00 00'))),
          const SizedBox(width: 8),
          FilterChip(label: const Text('HEX'), selected: _hexSend, onSelected: (v) => setState(() => _hexSend = v)),
          const SizedBox(width: 8),
          FilledButton.icon(onPressed: _connected ? _send : null, icon: const Icon(Icons.send, size: 18), label: const Text('发送'), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16))),
        ]),
      ]),
    );
  }
}
