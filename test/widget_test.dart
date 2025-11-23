// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:coffee_cart/main.dart';
import 'package:appwrite/appwrite.dart';

// English: The default Flutter counter test template was replaced with a
// minimal test that constructs MyApp with a stub Account(Client()). This is
// necessary because MyApp requires an Account parameter. The test now checks
// that the not-logged-in UI is shown.
//
// Arabic: تم استبدال قالب اختبار عداد Flutter الافتراضي باختبار بسيط ينشئ
// MyApp مع Account(Client()). هذا مطلوب لأن MyApp يتطلّب معامل Account.
// الآن يتحقق الاختبار من عرض واجهة المستخدم الخاصة بعدم تسجيل الدخول.

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame with a minimal Account instance.
    final client = Client();
    final account = Account(client);
    await tester.pumpWidget(MyApp(account: account));

    // Verify that the app shows the not-logged-in UI.
    expect(find.textContaining('Not logged in'), findsOneWidget);
  });
}
