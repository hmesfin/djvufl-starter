import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/utils/validators.dart';
import '../../../../shared/widgets/offline_banner.dart';
import '../../data/models/project_models.dart';
import '../providers/projects_provider.dart';

/// Project Form Screen
///
/// Create or edit a project with form validation.
/// Includes date pickers for start and due dates.
class ProjectFormScreen extends ConsumerStatefulWidget {
  const ProjectFormScreen({super.key, this.projectUuid});

  final String? projectUuid;

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  ProjectStatus? _selectedStatus = ProjectStatus.draft;
  ProjectPriority? _selectedPriority = ProjectPriority.medium;
  DateTime? _startDate;
  DateTime? _dueDate;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.projectUuid != null) {
      _loadProject();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadProject() async {
    setState(() => _isLoading = true);

    try {
      final project = await ref
          .read(projectsRepositoryProvider)
          .get(widget.projectUuid!);
      if (mounted) {
        _nameController.text = project.name;
        _descriptionController.text = project.description ?? '';
        _selectedStatus = project.status;
        _selectedPriority = project.priority;
        _startDate = project.startDate;
        _dueDate = project.dueDate;
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('y-MM-dd').format(date);
  }

  Future<void> _selectDate(bool isStartDate) async {
    final initial = isStartDate
        ? _startDate ?? DateTime.now()
        : _dueDate ?? _startDate ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // If due date is before start date, clear it
          if (_dueDate != null && _dueDate!.isBefore(_startDate!)) {
            _dueDate = null;
          }
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      if (widget.projectUuid != null) {
        // Update existing project
        final request = ProjectUpdateRequest(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          status: _selectedStatus,
          priority: _selectedPriority,
          startDate: _startDate,
          dueDate: _dueDate,
        );
        await ref
            .read(projectsProvider.notifier)
            .updateProject(widget.projectUuid!, request);
      } else {
        // Create new project
        final request = ProjectCreateRequest(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          status: _selectedStatus,
          priority: _selectedPriority,
          startDate: _startDate,
          dueDate: _dueDate,
        );
        await ref.read(projectsProvider.notifier).createProject(request);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.projectUuid != null;

    if (_isLoading && isEditMode) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading project...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Project' : 'Create Project'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Offline banner at the top
            const OfflineBanner(),

            // Form content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Error Message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    enabled: !_isLoading,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Project Name *',
                      hintText: 'Enter project name',
                      border: OutlineInputBorder(),
                    ),
                    validator: validateProjectName,
                  ),
                  const SizedBox(height: 16),

                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
                    enabled: !_isLoading,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter project description (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status Dropdown
                  DropdownButtonFormField<ProjectStatus>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: ProjectStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      );
                    }).toList(),
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          },
                  ),
                  const SizedBox(height: 16),

                  // Priority Dropdown
                  DropdownButtonFormField<ProjectPriority>(
                    initialValue: _selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: ProjectPriority.values.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority.label),
                      );
                    }).toList(),
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _selectedPriority = value;
                            });
                          },
                  ),
                  const SizedBox(height: 16),

                  // Start Date Field
                  InkWell(
                    onTap: _isLoading ? null : () => _selectDate(true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        hintText: 'Select start date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(_formatDate(_startDate)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Due Date Field
                  InkWell(
                    onTap: _isLoading ? null : () => _selectDate(false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Due Date',
                        hintText: 'Select due date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(_formatDate(_dueDate)),
                    ),
                  ),

                  // Date validation error
                  if (_startDate != null &&
                      _dueDate != null &&
                      _dueDate!.isBefore(_startDate!))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Due date must be after start date',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Submit Button
                  FilledButton(
                    onPressed:
                        (_isLoading ||
                            (_startDate != null &&
                                _dueDate != null &&
                                _dueDate!.isBefore(_startDate!)))
                        ? null
                        : _handleSubmit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEditMode ? 'Update Project' : 'Create Project',
                          ),
                  ),
                  const SizedBox(height: 8),

                  // Cancel Button
                  OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
