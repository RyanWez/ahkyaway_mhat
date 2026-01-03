import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ahkyaway_mhat/screens/dashboard/widgets/compact_stat_card.dart';
import 'package:ahkyaway_mhat/theme/app_theme.dart';

void main() {
  group('CompactStatCard', () {
    testWidgets('should display title and value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactStatCard(
              title: 'Active Debts',
              value: '5',
              icon: Icons.money,
              color: AppTheme.primaryDark,
              isDark: false,
            ),
          ),
        ),
      );

      // Allow animations to complete
      await tester.pumpAndSettle();

      expect(find.text('Active Debts'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('should display icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactStatCard(
              title: 'Test',
              value: '10',
              icon: Icons.people,
              color: AppTheme.successColor,
              isDark: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('should render in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: CompactStatCard(
              title: 'Completed',
              value: '3',
              icon: Icons.check_circle,
              color: AppTheme.successColor,
              isDark: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('should render in light mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: CompactStatCard(
              title: 'Total',
              value: '8',
              icon: Icons.account_balance_wallet,
              color: AppTheme.primaryLight,
              isDark: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Total'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('should handle zero value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactStatCard(
              title: 'Empty',
              value: '0',
              icon: Icons.inbox,
              color: Colors.grey,
              isDark: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Empty'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('should animate with different animationIndex', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CompactStatCard(
                  title: 'First',
                  value: '1',
                  icon: Icons.one_k,
                  color: Colors.blue,
                  isDark: false,
                  animationIndex: 0,
                ),
                CompactStatCard(
                  title: 'Second',
                  value: '2',
                  icon: Icons.two_k,
                  color: Colors.green,
                  isDark: false,
                  animationIndex: 1,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
    });
  });
}
