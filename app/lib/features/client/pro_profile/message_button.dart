import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/models/chat_thread_create_request.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/core/router/app_router_client.dart';
import 'package:rawwers/design/components/r_button.dart';

/// "Message" on a photographer's profile: ask before booking.
///
/// Opens the conversation with this photographer - the server returns the
/// existing one if there is one rather than starting a second - and goes to
/// it. Works whether or not the photographer's assistant is switched on.
class MessageButton extends ConsumerStatefulWidget {
  const MessageButton({required this.proUserId, required this.proName, super.key});

  final String proUserId;
  final String proName;

  @override
  ConsumerState<MessageButton> createState() => _MessageButtonState();
}

class _MessageButtonState extends ConsumerState<MessageButton> {
  bool _opening = false;

  Future<void> _open() async {
    setState(() => _opening = true);
    final client = ref.read(aiConciergeClientProvider);
    final result = await apiCall(
      () => client.createChatThreadV1V1ChatThreadsPost(
        requestBody: ChatThreadCreateRequest(proUserId: widget.proUserId),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    if (!mounted) return;
    setState(() => _opening = false);
    switch (result) {
      case Ok(:final value):
        await context.push(ClientRoute.thread(value.id));
      case Err():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the conversation. Try again.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) => RButton(
        label: 'Message ${widget.proName}',
        variant: RButtonVariant.secondary,
        loading: _opening,
        onPressed: _opening ? null : _open,
      );
}
