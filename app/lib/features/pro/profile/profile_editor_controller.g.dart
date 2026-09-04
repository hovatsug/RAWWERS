// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_editor_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileEditorControllerHash() =>
    r'8eb910d1b68f5b1af841015d429a913118115d69';

/// Saves edits to the pro profile.
///
/// Writes through [ProProfileController] rather than holding a second copy:
/// Settings, the listing preview and this screen all read that provider, so
/// a save has to update the one everything watches or the card the pro just
/// changed keeps showing the old value.
///
/// Copied from [ProfileEditorController].
@ProviderFor(ProfileEditorController)
final profileEditorControllerProvider =
    AutoDisposeAsyncNotifierProvider<ProfileEditorController, void>.internal(
      ProfileEditorController.new,
      name: r'profileEditorControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$profileEditorControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProfileEditorController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
