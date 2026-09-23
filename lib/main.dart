import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

void main() {
  runApp(const SerialTerminalApp());
}

class SerialTerminalApp extends StatelessWidget {
  const SerialTerminalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serial Terminal',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const SerialTerminalPage(),
    );
  }
}

class SerialTerminalPage extends StatefulWidget {
  const SerialTerminalPage({super.key});

  @override
  State<SerialTerminalPage> createState() => _SerialTerminalPageState();
}

class _SerialTerminalPageState extends State<SerialTerminalPage> {
  final _sendController = TextEditingController();
  final _logController = ScrollController();
  SerialPort? _port;
  SerialPortReader? _reader;
  StreamSubscription<Uint8List>? _subscription;
  List<String> _ports = const [];
  String? _selectedPort;
  int _baudRate = 115200;
  bool _connected = false;
  bool _hexReceive = false;
  bool _hexSend = false;
  bool _autoScroll = true;
  final List<String> _lines = [];

  @override
  void initState() {
    super.initState();
    _refreshPorts();
  }

  @override
  void dispose() {
    _disconnect();
    _sendController.dispose();
    _logController.dispose();
    super.dispose();
  }

  void _refreshPorts() {
    setState(() {
      _ports = SerialPort.availablePorts;
      _selectedPort = _ports.contains(_selectedPort)
          ? _selectedPort
          : (_ports.isEmpty ? null : _ports.first);
    });
  }

  void _connect() {
    final name = _selectedPort;
    if (name == null) return;
    final port = SerialPort(name);
    if (!port.openReadWrite()) {
      _append('打开 $name 失败: ${SerialPort.lastError}');
      port.dispose();
      return;
    }
    final config = port.config;
    config.baudRate = _baudRate;
    port.config = config;
    final reader = SerialPortReader(port);
    _subscription = reader.stream.listen(_receive);
    setState(() {
      _port = port;
      _reader = reader;
      _connected = true;
    });
    _append('已连接 $name @ $_baudRate');
  }

  void _disconnect() {
    _subscription?.cancel();
    _subscription = null;
    _reader = null;
    _port?.close();
    _port?.dispose();
    _port = null;
    if (mounted) setState(() => _connected = false);
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
    final Uint8List data;
    if (_hexSend) {
      final bytes = text
          .split(RegExp(r'[ ,]+'))
          .where((item) => item.isNotEmpty)
          .map((item) => int.parse(item, radix: 16))
          .toList();
      data = Uint8List.fromList(bytes);
    } else {
      data = Uint8List.fromList(utf8.encode(text));
    }
    port.write(data);
    _append('TX  $text');
  }

  void _append(String line) {
    setState(() => _lines.add('${DateTime.now().toLocal().toIso8601String()}  $line'));
    if (_autoScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_logController.hasClients) {
          _logController.jumpTo(_logController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Serial Terminal')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 170,
                  child: DropdownButtonFormField<String>(
                    value: _selectedPort,
                    decoration: const InputDecoration(labelText: '串口'),
                    items: _ports.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                    onChanged: _connected ? null : (value) => setState(() => _selectedPort = value),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<int>(
                    value: _baudRate,
                    decoration: const InputDecoration(labelText: '波特率'),
                    items: [9600, 19200, 38400, 57600, 115200]
                        .map((rate) => DropdownMenuItem(value: rate, child: Text('$rate')))
                        .toList(),
                    onChanged: _connected ? null : (value) => setState(() => _baudRate = value!),
                  ),
                ),
                IconButton(onPressed: _refreshPorts, tooltip: '刷新串口', icon: const Icon(Icons.refresh)),
                FilledButton.icon(
                  onPressed: _selectedPort == null ? null : (_connected ? _disconnect : _connect),
                  icon: Icon(_connected ? Icons.link_off : Icons.link),
                  label: Text(_connected ? '断开' : '连接'),
                ),
                FilterChip(label: const Text('HEX 接收'), selected: _hexReceive, onSelected: (v) => setState(() => _hexReceive = v)),
                FilterChip(label: const Text('自动滚动'), selected: _autoScroll, onSelected: (v) => setState(() => _autoScroll = v)),
                OutlinedButton(onPressed: () => setState(_lines.clear), child: const Text('清空')),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: ListView.builder(
                  controller: _logController,
                  itemCount: _lines.length,
                  itemBuilder: (_, index) => SelectableText(_lines[index]),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _sendController, decoration: const InputDecoration(labelText: '发送内容'))),
                const SizedBox(width: 8),
                FilterChip(label: const Text('HEX 发送'), selected: _hexSend, onSelected: (v) => setState(() => _hexSend = v)),
                const SizedBox(width: 8),
                FilledButton(onPressed: _connected ? _send : null, child: const Text('发送')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
