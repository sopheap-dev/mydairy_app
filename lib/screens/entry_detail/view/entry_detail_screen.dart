import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mydairy/app/config/di/di.dart';
import 'package:mydairy/app/core/constants/gradient_colors.dart';
import 'package:mydairy/app/core/services/image_share_service.dart';
import 'package:mydairy/app/core/services/share_service.dart';
import 'package:mydairy/app/core/widgets/mood_badge.dart';
import 'package:mydairy/app/core/widgets/recommendation_card.dart';
import 'package:mydairy/app/core/widgets/shareable_card.dart';
import 'package:mydairy/domain/repositories/diary_repository.dart';
import 'package:mydairy/domain/entities/diary_entry.dart';

class EntryDetailScreen extends StatelessWidget {
  final String entryId;

  const EntryDetailScreen({
    required this.entryId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DiaryEntry?>(
      future: _loadEntry(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Entry Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64),
                  const SizedBox(height: 16),
                  const Text('Entry not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return EntryDetailView(entry: snapshot.data!);
      },
    );
  }

  Future<DiaryEntry?> _loadEntry() async {
    final repository = getIt<DiaryRepository>();
    final result = await repository.getEntry(entryId);
    return result.fold(
      (failure) => null,
      (entry) => entry,
    );
  }
}

class EntryDetailView extends StatelessWidget {
  final DiaryEntry entry;

  const EntryDetailView({
    required this.entry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareEntry(context),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDelete(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header with mood
          if (entry.aiMood != null)
            Center(
              child: MoodBadge(mood: entry.aiMood!, size: 60),
            ),
          const SizedBox(height: 16),

          // Title
          Text(
            entry.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Date and time
          Text(
            '${dateFormat.format(entry.date)} at ${timeFormat.format(entry.createdAt)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Tags
          if (entry.tags.isNotEmpty) ...[
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: entry.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // AI Summary
          if (entry.aiSummary != null) ...[
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI Summary',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      entry.aiSummary!,
                      style: theme.textTheme.bodyLarge,
                    ),
                    if (entry.aiConfidence != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Confidence: ',
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            '${(entry.aiConfidence! * 100).toStringAsFixed(0)}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Body
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Entry',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    entry.body,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Recommendations
          if (entry.aiRecommendations != null &&
              entry.aiRecommendations!.isNotEmpty)
            RecommendationCard(
              recommendations: entry.aiRecommendations!,
              empathy: entry.aiEmpathy,
            ),

          // Safety alert
          if (entry.hasSafetyAlert) ...[
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Support Resources',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'If you\'re experiencing thoughts of self-harm, please reach out for help. You don\'t have to face this alone.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Open crisis helpline resources
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Crisis Resources'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Analyzing indicator
          if (entry.isPendingAnalysis) ...[
            Card(
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
                        'AI analysis is in progress...',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _shareEntry(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => _ShareOptionsSheet(entry: entry),
    );

    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  void _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
          'Are you sure you want to delete this entry? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final repository = getIt<DiaryRepository>();
      await repository.deleteEntry(entry.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry deleted')),
        );
        context.pop();
      }
    }
  }
}

class _ShareOptionsSheet extends StatefulWidget {
  final DiaryEntry entry;

  const _ShareOptionsSheet({required this.entry});

  @override
  State<_ShareOptionsSheet> createState() => _ShareOptionsSheetState();
}

class _ShareOptionsSheetState extends State<_ShareOptionsSheet> {
  ShareCardStyle _selectedStyle = ShareCardStyle.insight;
  String _selectedTheme = 'auto';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  'Share as Image',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create beautiful shareable cards',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preview Card
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: OverflowBox(
                        maxHeight: 600,
                        child: Transform.scale(
                          scale: 0.5,
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: 400,
                            height: 600,
                            child: ShareableCard(
                              entry: widget.entry,
                              style: _selectedStyle,
                              useGradient: _selectedTheme != 'white',
                              customTheme: _selectedTheme == 'auto'
                                  ? null
                                  : _selectedTheme,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Style Selection
                  Text(
                    'Content Style',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<ShareCardStyle>(
                    segments: const [
                      ButtonSegment(
                        value: ShareCardStyle.moodOnly,
                        label: Text('Mood'),
                        icon: Icon(Icons.mood, size: 18),
                      ),
                      ButtonSegment(
                        value: ShareCardStyle.insight,
                        label: Text('Insight'),
                        icon: Icon(Icons.lightbulb, size: 18),
                      ),
                      ButtonSegment(
                        value: ShareCardStyle.full,
                        label: Text('Full'),
                        icon: Icon(Icons.article, size: 18),
                      ),
                    ],
                    selected: {_selectedStyle},
                    onSelectionChanged: (Set<ShareCardStyle> newSelection) {
                      setState(() {
                        _selectedStyle = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Theme Selection
                  Text(
                    'Background Theme',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _ThemeOption(
                        label: 'Auto',
                        colors: widget.entry.aiMood != null
                            ? GradientColors.getGradientForMood(
                                widget.entry.aiMood!)
                            : [Colors.grey.shade300, Colors.grey.shade400],
                        isSelected: _selectedTheme == 'auto',
                        onTap: () => setState(() => _selectedTheme = 'auto'),
                      ),
                      _ThemeOption(
                        label: 'Sunset',
                        colors: GradientColors.getThemeGradient('sunset'),
                        isSelected: _selectedTheme == 'sunset',
                        onTap: () => setState(() => _selectedTheme = 'sunset'),
                      ),
                      _ThemeOption(
                        label: 'Ocean',
                        colors: GradientColors.getThemeGradient('ocean'),
                        isSelected: _selectedTheme == 'ocean',
                        onTap: () => setState(() => _selectedTheme = 'ocean'),
                      ),
                      _ThemeOption(
                        label: 'Forest',
                        colors: GradientColors.getThemeGradient('forest'),
                        isSelected: _selectedTheme == 'forest',
                        onTap: () => setState(() => _selectedTheme = 'forest'),
                      ),
                      _ThemeOption(
                        label: 'Lavender',
                        colors: GradientColors.getThemeGradient('lavender'),
                        isSelected: _selectedTheme == 'lavender',
                        onTap: () =>
                            setState(() => _selectedTheme = 'lavender'),
                      ),
                      _ThemeOption(
                        label: 'Peach',
                        colors: GradientColors.getThemeGradient('peach'),
                        isSelected: _selectedTheme == 'peach',
                        onTap: () => setState(() => _selectedTheme = 'peach'),
                      ),
                      _ThemeOption(
                        label: 'Mint',
                        colors: GradientColors.getThemeGradient('mint'),
                        isSelected: _selectedTheme == 'mint',
                        onTap: () => setState(() => _selectedTheme = 'mint'),
                      ),
                      _ThemeOption(
                        label: 'Rose',
                        colors: GradientColors.getThemeGradient('rose'),
                        isSelected: _selectedTheme == 'rose',
                        onTap: () => setState(() => _selectedTheme = 'rose'),
                      ),
                      _ThemeOption(
                        label: 'Cosmic',
                        colors: GradientColors.getThemeGradient('cosmic'),
                        isSelected: _selectedTheme == 'cosmic',
                        onTap: () => setState(() => _selectedTheme = 'cosmic'),
                      ),
                      _ThemeOption(
                        label: 'White',
                        colors: [Colors.white, Colors.white],
                        isSelected: _selectedTheme == 'white',
                        onTap: () => setState(() => _selectedTheme = 'white'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Share to Social Media Button (Primary Action)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _shareToSocialMedia,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.share),
                    label: Text(_isLoading
                        ? 'Preparing...'
                        : 'Share to Apps'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Secondary Actions Row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _saveToGallery,
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Save'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _shareAsText,
                        icon: const Icon(Icons.text_fields, size: 18),
                        label: const Text('Text'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveToGallery() async {
    setState(() => _isLoading = true);

    try {
      final success = await ImageShareService.captureAndSaveToGallery(
        entry: widget.entry,
        style: _selectedStyle,
        useGradient: _selectedTheme != 'white',
        customTheme: _selectedTheme == 'auto' ? null : _selectedTheme,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (success) {
        Navigator.pop(
          context,
          '✓ Image saved to gallery! You can share it from your photos',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to save image. Please check storage permissions.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareToSocialMedia() async {
    setState(() => _isLoading = true);

    try {
      final success = await ImageShareService.shareToSocialMedia(
        entry: widget.entry,
        style: _selectedStyle,
        useGradient: _selectedTheme != 'white',
        customTheme: _selectedTheme == 'auto' ? null : _selectedTheme,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (success) {
        Navigator.pop(
          context,
          '✓ Shared successfully!',
        );
      } else {
        // User might have dismissed the share sheet, don't show error
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _shareAsText() async {
    String message;
    switch (_selectedStyle) {
      case ShareCardStyle.moodOnly:
        final text = ShareService.buildPrivacyShareText(widget.entry);
        await Clipboard.setData(ClipboardData(text: text));
        message = '✓ Mood copied to clipboard!';
        break;
      case ShareCardStyle.insight:
        final text = ShareService.buildShareableInsight(widget.entry);
        await Clipboard.setData(ClipboardData(text: text));
        message = '✓ Insight copied to clipboard!';
        break;
      case ShareCardStyle.full:
        await ShareService.shareEntryAsText(widget.entry);
        message = '✓ Full entry copied to clipboard!';
        break;
    }

    if (mounted) {
      Navigator.pop(context, message);
    }
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final List<Color> colors;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.colors,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withAlpha(100),
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(11),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(11),
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
