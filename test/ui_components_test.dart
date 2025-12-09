import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh_sdk_flutter/src/l10n/mesh_localizations.dart';
import 'package:mesh_sdk_flutter/src/ui/dialog/exit_dialog.dart';
import 'package:mesh_sdk_flutter/src/ui/theme.dart';
import 'package:mesh_sdk_flutter/src/ui/widget/mesh_link_nav_bar.dart';

void main() {
  group('ExitDialog', () {
    Widget buildTestApp({required VoidCallback onConfirm}) {
      return MaterialApp(
        localizationsDelegates: MeshLocalizations.localizationsDelegates,
        supportedLocales: MeshLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => ExitDialog(onConfirm: onConfirm),
              ),
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );
    }

    testWidgets('renders title and message', (tester) async {
      await tester.pumpWidget(buildTestApp(onConfirm: () {}));
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to exit?'), findsOneWidget);
      expect(find.text('Your progress will be lost.'), findsOneWidget);
      expect(find.text('Exit'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('cancel button dismisses dialog', (tester) async {
      await tester.pumpWidget(buildTestApp(onConfirm: () {}));
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('exit button calls onConfirm and dismisses', (tester) async {
      var confirmCalled = false;

      await tester.pumpWidget(buildTestApp(onConfirm: () {
        confirmCalled = true;
      }));
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();

      expect(confirmCalled, isTrue);
      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  group('MeshLinkNavBar', () {
    testWidgets('renders back and close buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeshLinkNavBar(
              brightness: Brightness.light,
              onBackPressed: () {},
              onClosePressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('back button calls onBackPressed', (tester) async {
      var backPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeshLinkNavBar(
              brightness: Brightness.light,
              onBackPressed: () {
                backPressed = true;
              },
              onClosePressed: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();

      expect(backPressed, isTrue);
    });

    testWidgets('close button calls onClosePressed', (tester) async {
      var closePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeshLinkNavBar(
              brightness: Brightness.dark,
              onBackPressed: () {},
              onClosePressed: () {
                closePressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(closePressed, isTrue);
    });
  });

  group('theme', () {
    test('getNavBarColor returns light color for Brightness.light', () {
      final color = getNavBarColor(Brightness.light);
      expect(color, navBarColorLight);
    });

    test('getNavBarColor returns dark color for Brightness.dark', () {
      final color = getNavBarColor(Brightness.dark);
      expect(color, navBarColorDark);
    });
  });
}