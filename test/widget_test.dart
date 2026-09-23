import 'package:flutter_test/flutter_test.dart';

import 'package:serial_terminal/main.dart';

void main() {
  testWidgets('shows the serial terminal shell', (tester) async {
    await tester.pumpWidget(const SerialTerminalApp(loadPorts: false));

    expect(find.text('串口调试助手'), findsOneWidget);
    expect(find.text('打开串口'), findsOneWidget);
    expect(find.text('发送'), findsOneWidget);
    expect(find.text('版本 0.0.1'), findsOneWidget);
  });
}
