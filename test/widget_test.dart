import 'package:flutter_test/flutter_test.dart';

import 'package:serial_terminal/main.dart';

void main() {
  testWidgets('shows the serial terminal shell', (tester) async {
    await tester.pumpWidget(const SerialTerminalApp(loadPorts: false));

    expect(find.text('Serial Terminal'), findsOneWidget);
    expect(find.text('连接'), findsOneWidget);
    expect(find.text('发送'), findsOneWidget);
  });
}
