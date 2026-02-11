import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/project_widgets.dart';
import '../../data/models/project_models.dart';
import '../providers/projects_provider.dart';

/// Project Detail Screen
///
/// Displays detailed information about a single project
/// with options to edit or delete.
class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({
    super.key,
    required this.projectUuid,
  });

  final String projectUuid;

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d, y').format(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectProvider(projectUuid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        actions: [
          if (projectAsync.value != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Navigate to edit form
              },
            ),
          ],
      ),
      body: projectAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading project...'),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to Load Project',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
        data: (project) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Name
              Text(
                project.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Badges Row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusBadge(status: project.status),
                  PriorityBadge(priority: project.priority),
                  // Overdue indicator
                  if (_isOverdue(project))
                    _OverdueBadge(),
                ],
              ),
              const SizedBox(height: 24),

              // Description
              if (project.description != null && project.description!.isNotEmpty)
                _Section(
                  title: 'Description',
                  child: Text(
                    project.description!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                        ),
                  ),
                ),

              // Dates Section
              if (project.startDate != null || project.dueDate != null)
                _Section(
                  title: 'Timeline',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (project.startDate != null)
                        _DateRow(
                          label: 'Start Date:',
                          date: _formatDate(project.startDate),
                        ),
                      if (project.dueDate != null)
                        _DateRow(
                          label: 'Due Date:',
                          date: _formatDate(project.dueDate),
                        ),
                    ],
                  ),
                ),

              // Metadata Section
              _Section(
                title: 'Metadata',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MetadataRow(
                      label: 'Created:',
                      value: _formatDate(project.createdAt),
                    ),
                    _MetadataRow(
                      label: 'Last Updated:',
                      value: _formatDate(project.updatedAt),
                    ),
                    _MetadataRow(
                      label: 'UUID:',
                      value: project.uuid,
                    ),
                  ],
                ),
                showBorder: false,
              ),

              // Action Buttons
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: () {
                  // TODO: Navigate to edit form
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Edit Project'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => _showDeleteDialog(context, ref),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete Project'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isOverdue(Project project) {
    if (project.dueDate == null) return false;
    return project.dueDate!.isBefore(DateTime.now()) &&
        project.status != ProjectStatus.completed;
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text(
          'Are you sure you want to delete this project? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(projectsProvider.notifier).deleteProject(projectUuid);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete project: $e')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Section widget for grouping content
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.showBorder = true,
  });

  final String title;
  final Widget child;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        if (showBorder)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: child,
          )
        else
          child,
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Date row widget
class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.date,
  });

  final String label;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              date,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Metadata row widget
class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Overdue badge widget
class _OverdueBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Overdue',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
