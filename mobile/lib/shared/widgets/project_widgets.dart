import 'package:flutter/material.dart';
import '../../features/projects/data/models/project_models.dart';

/// Status badge widget
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
  });

  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(context, status);
    final label = status.label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _getStatusTextColor(context, status),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context, ProjectStatus status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return switch (status) {
      ProjectStatus.draft => isDark ? Colors.grey.shade700 : Colors.grey.shade400,
      ProjectStatus.active => Colors.blue,
      ProjectStatus.completed => Colors.green,
      ProjectStatus.archived => Colors.orange,
    };
  }

  Color _getStatusTextColor(BuildContext context, ProjectStatus status) {
    return switch (status) {
      ProjectStatus.draft => Colors.white,
      ProjectStatus.active => Colors.white,
      ProjectStatus.completed => Colors.white,
      ProjectStatus.archived => Colors.white,
    };
  }
}

/// Priority badge widget
class PriorityBadge extends StatelessWidget {
  const PriorityBadge({
    super.key,
    required this.priority,
  });

  final ProjectPriority priority;

  @override
  Widget build(BuildContext context) {
    final color = _getPriorityColor(context, priority);
    final label = priority.label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _getPriorityTextColor(context, priority),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getPriorityColor(BuildContext context, ProjectPriority priority) {
    return switch (priority) {
      ProjectPriority.low => Colors.grey,
      ProjectPriority.medium => const Color(0xFFFDD835), // Darker yellow
      ProjectPriority.high => Colors.orange,
      ProjectPriority.critical => Colors.red,
    };
  }

  Color _getPriorityTextColor(BuildContext context, ProjectPriority priority) {
    return switch (priority) {
      ProjectPriority.low => Colors.white,
      ProjectPriority.medium => Colors.black,
      ProjectPriority.high => Colors.white,
      ProjectPriority.critical => Colors.white,
    };
  }
}

/// Project card widget
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.onLongPress,
  });

  final Project project;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: name and badges
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              if (project.description != null && project.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    project.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Badges
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  StatusBadge(status: project.status),
                  PriorityBadge(priority: project.priority),
                ],
              ),

              // Dates
              if (project.startDate != null || project.dueDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      if (project.startDate != null)
                        Expanded(
                          child: _DateChip(
                            label: 'Start',
                            date: project.startDate!,
                          ),
                        ),
                      if (project.startDate != null && project.dueDate != null)
                        const SizedBox(width: 8),
                      if (project.dueDate != null)
                        Expanded(
                          child: _DateChip(
                            label: 'Due',
                            date: project.dueDate!,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Date chip widget for project card
class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.date,
  });

  final String label;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            _formatDate(date),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
