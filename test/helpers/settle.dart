import 'package:flutter_test/flutter_test.dart';

// Engine image decoding uses real asynchronous work, outside the fake clock.
// Yield to it between frames instead of advancing ten fake minutes in a loop.
Future<void> settle(WidgetTester tester) async {
  for (var frame = 0; frame < 1000; frame++) {
    await tester.pump(const Duration(milliseconds: 50));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    if (!tester.binding.hasScheduledFrame) return;
  }
  fail('The screen did not settle after image decoding and animations.');
}
