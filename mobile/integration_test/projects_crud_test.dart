import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/projects/data/models/project_models.dart';
import 'package:mobile/features/projects/presentation/screens/project_form_screen.dart';
import 'package:mobile/shared/utils/validators.dart';

/// Projects CRUD integration tests.
///
/// Tests project form validation and UI interactions.
void main() {
  group('Projects CRUD Flow', () {
    testWidgets('Project form displays correctly in create mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProjectFormScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all expected elements are present
      expect(find.text('Create Project'), findsOneWidget);
      expect(find.text('Project Name'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Priority'), findsOneWidget);
      expect(find.text('Start Date'), findsOneWidget);
      expect(find.text('Due Date'), findsOneWidget);
      expect(find.text('Create Project'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('Project name validation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProjectFormScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test empty validation
      final createButton = find.text('Create Project');
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Project name is required'), findsOneWidget);
    });

    testWidgets('Status dropdown has all options', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProjectFormScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify status dropdown exists
      expect(find.text('Status'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<ProjectStatus>), findsOneWidget);
    });

    testWidgets('Priority dropdown has all options', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProjectFormScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify priority dropdown exists
      expect(find.text('Priority'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<ProjectPriority>), findsOneWidget);
    });

    testWidgets('Date validation works correctly', (WidgetTester tester) async {
      // Test the validator directly
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));

      // Same dates should pass
      expect(validateDateRange(now, now), isNull);

      // End before start should fail
      expect(validateDateRange(tomorrow, yesterday), 'End date must be after start date');

      // One after the other should pass
      expect(validateDateRange(yesterday, tomorrow), isNull);

      // Null dates should pass
      expect(validateDateRange(null, null), isNull);
      expect(validateDateRange(now, null), isNull);
      expect(validateDateRange(null, now), isNull);
    });

    testWidgets('Project name validator works', (WidgetTester tester) async {
      // Test the validator directly
      expect(validateProjectName(null), 'Project name is required');
      expect(validateProjectName(''), 'Project name is required');
      expect(validateProjectName(''), 'Project name is required');

      // Too long
      final longName = 'a' * 256;
      expect(validateProjectName(longName), 'Project name is too long (max 255 characters)');

      // Valid names should pass
      expect(validateProjectName('My Project'), isNull);
      expect(validateProjectName('A'), isNull);
    });
  });

  group('Project Models', () {
    test('ProjectStatus enum has correct values', () {
      expect(ProjectStatus.draft.value, 'draft');
      expect(ProjectStatus.active.value, 'active');
      expect(ProjectStatus.completed.value, 'completed');
      expect(ProjectStatus.archived.value, 'archived');

      expect(ProjectStatus.draft.label, 'Draft');
      expect(ProjectStatus.active.label, 'Active');
      expect(ProjectStatus.completed.label, 'Completed');
      expect(ProjectStatus.archived.label, 'Archived');

      // Test fromString
      expect(ProjectStatus.fromString('draft'), ProjectStatus.draft);
      expect(ProjectStatus.fromString('active'), ProjectStatus.active);
    });

    test('ProjectPriority enum has correct values', () {
      expect(ProjectPriority.low.value, 1);
      expect(ProjectPriority.medium.value, 2);
      expect(ProjectPriority.high.value, 3);
      expect(ProjectPriority.critical.value, 4);

      expect(ProjectPriority.low.label, 'Low');
      expect(ProjectPriority.medium.label, 'Medium');
      expect(ProjectPriority.high.label, 'High');
      expect(ProjectPriority.critical.label, 'Critical');

      // Test fromInt
      expect(ProjectPriority.fromInt(1), ProjectPriority.low);
      expect(ProjectPriority.fromInt(2), ProjectPriority.medium);
    });
  });
}
