import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/interview_answer_view.dart';
import 'package:rawwers/api/models/meet_interview_item.dart';
import 'package:rawwers/api/models/meet_the_photographer_view.dart';
import 'package:rawwers/api/models/my_interview_view.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/interview/interview_controller.dart';
import 'package:rawwers/features/pro/settings/settings_controller.dart';
import 'package:rawwers/features/shared/meet/meet_section.dart';

/// "Meet the photographer": a few questions, answered in their own words,
/// for their profile. Optional - nothing else waits on it, and it changes
/// nothing about where they appear.
///
/// They write drafts, preview exactly what clients will read (the client's
/// own section widget) and publish. Lengths and the contact-details warning
/// come from the server; a warning never stops them.
class InterviewScreen extends ConsumerWidget {
  const InterviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(interviewControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Meet the photographer')),
      body: switch (state) {
        AsyncData(:final value) => _Editor(view: value),
        AsyncError() => RErrorState(
            message: 'Could not load your interview.',
            onRetry: () => ref.invalidate(interviewControllerProvider),
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Editor extends ConsumerStatefulWidget {
  const _Editor({required this.view});

  final MyInterviewView view;

  @override
  ConsumerState<_Editor> createState() => _EditorState();
}

class _EditorState extends ConsumerState<_Editor> {
  late final Map<String, TextEditingController> _text = {
    for (final item in widget.view.items) item.questionId: TextEditingController(text: item.draft ?? ''),
  };
  bool _busy = false;

  @override
  void dispose() {
    for (final c in _text.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, String?> get _drafts => {for (final e in _text.entries) e.key: e.value.text.trim().isEmpty ? null : e.value.text.trim()};

  Future<bool> _call(Future<String?> Function() action, {String? done}) async {
    setState(() => _busy = true);
    final error = await action();
    if (!mounted) return false;
    setState(() => _busy = false);
    final message = error ?? done;
    if (message != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    return error == null;
  }

  Future<void> _preview() async {
    final notifier = ref.read(interviewControllerProvider.notifier);
    if (!await _call(() => notifier.save(_drafts))) return;
    if (!mounted) return;
    String name = 'you';
    try {
      name = (await ref.read(proProfileControllerProvider.future)).displayName ?? name;
    } on Object {
      // The preview still shows the words; only the heading's name is generic.
    }
    if (!mounted) return;
    final items = widget.view.items;
    final preview = MeetThePhotographerView(
      interview: [
        for (final item in items)
          if ((_drafts[item.questionId] ?? '').isNotEmpty)
            MeetInterviewItem(questionId: item.questionId, title: item.title, answer: _drafts[item.questionId]!),
      ],
    );
    final publish = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => _Preview(name: name, view: preview)),
    );
    if (publish == true) await _call(notifier.publish, done: 'Published. It is on your profile now.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final view = ref.watch(interviewControllerProvider).valueOrNull ?? widget.view;
    final notifier = ref.read(interviewControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(RSpace.s16),
      children: [
        Text(
          'Optional. A few answers in your own words, shown on your profile under your photos. '
          'Clients read only what you publish.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: RSpace.s8),
        Text(_status(view), key: const ValueKey('interview-status'), style: theme.textTheme.bodySmall),
        const SizedBox(height: RSpace.s16),
        for (final item in view.items) ...[
          _Question(item: item, controller: _text[item.questionId] ?? TextEditingController()),
          const SizedBox(height: RSpace.s24),
        ],
        RButton(label: 'Preview and publish', onPressed: _busy ? null : _preview),
        const SizedBox(height: RSpace.s8),
        RButton(
          label: 'Save draft',
          variant: RButtonVariant.secondary,
          onPressed: _busy ? null : () => _call(() => notifier.save(_drafts), done: 'Draft saved.'),
        ),
        if (view.isPublished) ...[
          const SizedBox(height: RSpace.s8),
          RButton(
            label: 'Remove from my profile',
            variant: RButtonVariant.secondary,
            onPressed: _busy ? null : () => _call(notifier.unpublish, done: 'Removed from your profile. Your drafts are kept.'),
          ),
        ],
      ],
    );
  }

  String _status(MyInterviewView view) {
    if (!view.isPublished) return 'Not on your profile yet.';
    if (view.hasUnpublishedChanges) return 'On your profile. You have changes that are not published yet.';
    return 'On your profile.';
  }
}

class _Question extends StatefulWidget {
  const _Question({required this.item, required this.controller});

  final InterviewAnswerView item;
  final TextEditingController controller;

  @override
  State<_Question> createState() => _QuestionState();
}

class _QuestionState extends State<_Question> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  void _changed() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;
    final length = widget.controller.text.trim().length;
    final short = length > 0 && length < item.minChars;
    final warning = item.warning;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.prompt, style: theme.textTheme.titleSmall),
        if (item.hint != null) ...[
          const SizedBox(height: RSpace.s4),
          Text(item.hint!, style: theme.textTheme.bodySmall),
        ],
        const SizedBox(height: RSpace.s8),
        TextField(
          controller: widget.controller,
          minLines: 2,
          maxLines: 6,
          maxLength: item.maxChars,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: item.title,
            helperText: short ? 'At least ${item.minChars} characters to publish' : 'Clients see this as “${item.title}”',
          ),
        ),
        if (warning != null)
          Semantics(
            liveRegion: true,
            child: Row(
              key: ValueKey('contact-warning-${item.questionId}'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: RSpace.s16, color: theme.colorScheme.tertiary),
                const SizedBox(width: RSpace.s8),
                Expanded(child: Text(warning, style: theme.textTheme.bodySmall)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Exactly what a client will read - the profile's own section - before it
/// goes there.
class _Preview extends StatelessWidget {
  const _Preview({required this.name, required this.view});

  final String name;
  final MeetThePhotographerView view;

  @override
  Widget build(BuildContext context) {
    final empty = view.interview?.isEmpty ?? true;
    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: ListView(
        padding: const EdgeInsets.all(RSpace.s16),
        children: [
          Text('This is what clients will read on your profile.', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: RSpace.s16),
          if (empty) const Text('Nothing to show yet: answer at least one question.') else MeetSection(name: name, meet: view),
          const SizedBox(height: RSpace.s16),
          RButton(label: 'Publish', onPressed: empty ? null : () => Navigator.of(context).pop(true)),
          const SizedBox(height: RSpace.s8),
          RButton(label: 'Keep editing', variant: RButtonVariant.secondary, onPressed: () => Navigator.of(context).pop(false)),
        ],
      ),
    );
  }
}
