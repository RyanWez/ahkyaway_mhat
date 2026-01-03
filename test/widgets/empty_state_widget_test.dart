import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ahkyaway_mhat/widgets/empty_state_widget.dart';
import 'package:ahkyaway_mhat/theme/app_theme.dart';

void main() {
  group('EmptyStateWidget', () {
    testWidgets('should display icon, title and subtitle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox_outlined,
              title: 'No Items',
              subtitle: 'Add your first item to get started',
              isDark: false,
            ),
          ),
        ),
      );

      // First frame
      await tester.pump();

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.text('No Items'), findsOneWidget);
      expect(find.text('Add your first item to get started'), findsOneWidget);
    });

    testWidgets('should display action button when provided', (tester) async {
      bool actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.person_add,
              title: 'No Customers',
              subtitle: 'Add a customer',
              isDark: false,
              actionLabel: 'Add Customer',
              onAction: () => actionCalled = true,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Add Customer'), findsOneWidget);

      // Tap the action button
      await tester.tap(find.text('Add Customer'));
      await tester.pump();

      expect(actionCalled, true);
    });

    testWidgets('should not display action button when not provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.error,
              title: 'Error',
              subtitle: 'Something went wrong',
              isDark: false,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('should render in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.cloud_off,
              title: 'Offline',
              subtitle: 'No internet connection',
              isDark: true,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Offline'), findsOneWidget);
    });

    testWidgets('should use custom icon color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.warning,
              title: 'Warning',
              subtitle: 'Be careful',
              isDark: false,
              iconColor: Colors.orange,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('should use custom icon size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.star,
              title: 'Featured',
              subtitle: 'Special content',
              isDark: false,
              iconSize: 100,
            ),
          ),
        ),
      );

      await tester.pump();

      final icon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(icon.size, 100);
    });
  });

  group('CompactEmptyState', () {
    testWidgets('should display icon and title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactEmptyState(
              icon: Icons.check_circle,
              title: 'All Clear',
              isDark: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('All Clear'), findsOneWidget);
    });

    testWidgets('should display subtitle when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactEmptyState(
              icon: Icons.info,
              title: 'Info',
              subtitle: 'Additional details here',
              isDark: false,
            ),
          ),
        ),
      );

      expect(find.text('Info'), findsOneWidget);
      expect(find.text('Additional details here'), findsOneWidget);
    });

    testWidgets('should not display subtitle when not provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactEmptyState(
              icon: Icons.done,
              title: 'Complete',
              isDark: true,
            ),
          ),
        ),
      );

      expect(find.text('Complete'), findsOneWidget);
      // Only title text should exist
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('should use custom icon color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactEmptyState(
              icon: Icons.favorite,
              title: 'Favorites',
              isDark: false,
              iconColor: Colors.red,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });
}
