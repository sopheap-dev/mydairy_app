import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mydairy/app/config/di/di.dart';
import 'package:mydairy/screens/write_entry/cubit/write_entry_cubit.dart';
import 'package:mydairy/screens/write_entry/cubit/write_entry_state.dart';

class WriteEntryScreen extends StatelessWidget {
  const WriteEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WriteEntryCubit(
        saveEntryUsecase: getIt(),
        analyzeEntryUsecase: getIt(),
      ),
      child: const WriteEntryView(),
    );
  }
}

class WriteEntryView extends StatefulWidget {
  const WriteEntryView({super.key});

  @override
  State<WriteEntryView> createState() => _WriteEntryViewState();
}

class _WriteEntryViewState extends State<WriteEntryView> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _tagController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<String> _tags = [];
  bool _analyzeWithAI = true;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<WriteEntryCubit, WriteEntryState>(
      listener: (context, state) {
        if (state.status == WriteEntryStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.entry?.hasSafetyAlert == true
                    ? '⚠️ Entry saved. Please seek support if needed.'
                    : state.entry?.aiMood != null
                        ? '✓ Entry saved and analyzed!'
                        : '✓ Entry saved!',
              ),
              backgroundColor: state.entry?.hasSafetyAlert == true
                  ? Colors.orange
                  : Colors.green,
            ),
          );
          context.pop();
        } else if (state.status == WriteEntryStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to save entry'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;

          final cubit = context.read<WriteEntryCubit>();
          if (cubit.state.hasUnsavedChanges) {
            final shouldPop = await _showUnsavedChangesDialog(context);
            if (shouldPop == true && context.mounted) {
              context.pop();
            }
          } else {
            if (context.mounted) context.pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('New Entry'),
            actions: [
              BlocBuilder<WriteEntryCubit, WriteEntryState>(
                builder: (context, state) {
                  if (state.status == WriteEntryStatus.saving ||
                      state.status == WriteEntryStatus.analyzing) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  return IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: _saveEntry,
                  );
                },
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'What happened today?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: theme.textTheme.titleLarge,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onChanged: (_) => context.read<WriteEntryCubit>().markAsChanged(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bodyController,
                  decoration: InputDecoration(
                    labelText: 'How are you feeling?',
                    hintText: 'Write your thoughts here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 12,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please write something';
                    }
                    if (value.trim().length < 10) {
                      return 'Entry should be at least 10 characters';
                    }
                    return null;
                  },
                  onChanged: (_) => context.read<WriteEntryCubit>().markAsChanged(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _tagController,
                        decoration: InputDecoration(
                          labelText: 'Add Tag',
                          hintText: 'e.g., work, family, health',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onFieldSubmitted: (_) => _addTag(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _addTag,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                if (_tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        onDeleted: () {
                          setState(() {
                            _tags.remove(tag);
                          });
                          context.read<WriteEntryCubit>().markAsChanged();
                        },
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 24),
                Card(
                  child: SwitchListTile(
                    title: const Text('Analyze with AI'),
                    subtitle: const Text(
                      'Get mood analysis and personalized recommendations',
                    ),
                    value: _analyzeWithAI,
                    onChanged: (value) {
                      setState(() {
                        _analyzeWithAI = value;
                      });
                    },
                    secondary: const Icon(Icons.psychology),
                  ),
                ),
                const SizedBox(height: 16),
                BlocBuilder<WriteEntryCubit, WriteEntryState>(
                  builder: (context, state) {
                    if (state.status == WriteEntryStatus.analyzing) {
                      return Card(
                        color: theme.colorScheme.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'AI is analyzing your entry...',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
      context.read<WriteEntryCubit>().markAsChanged();
    }
  }

  void _saveEntry() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<WriteEntryCubit>().saveEntry(
            title: _titleController.text,
            body: _bodyController.text,
            tags: _tags,
            analyzeWithAI: _analyzeWithAI,
          );
    }
  }

  Future<bool?> _showUnsavedChangesDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }
}
