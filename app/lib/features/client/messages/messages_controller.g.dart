// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messagesControllerHash() =>
    r'1e9fa3ed67ca9196a99aeca4f76b2bbd1a5cb9e6';

/// The client's own chat threads.
///
/// Ordered by `created_at`, not last activity - that is the endpoint's
/// ordering, chosen because a keyset cursor needs a stable sort key and
/// `updated_at` moves every time a message arrives. Thread counts per client
/// are small, so the difference is rarely visible.
///
/// Copied from [MessagesController].
@ProviderFor(MessagesController)
final messagesControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      MessagesController,
      CursorPage<ChatThreadSummary>
    >.internal(
      MessagesController.new,
      name: r'messagesControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$messagesControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MessagesController =
    AutoDisposeAsyncNotifier<CursorPage<ChatThreadSummary>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
