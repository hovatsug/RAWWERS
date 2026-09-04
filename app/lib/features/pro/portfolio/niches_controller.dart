import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

part 'niches_controller.g.dart';

/// A niche, as the tagging UI needs it.
///
/// GET /v1/niches returns bare `{slug, name}` maps rather than a schema,
/// so this reads them defensively and drops anything malformed instead of
/// throwing - a single odd row should not empty the picker.
class NicheOption {
  const NicheOption({required this.slug, required this.name});

  final String slug;
  final String name;
}

@Riverpod(keepAlive: true)
class NichesController extends _$NichesController {
  @override
  Future<List<NicheOption>> build() async {
    final client = ref.read(proOnboardingClientProvider);
    final result = await apiCall(() => client.listNichesV1NichesGet());
    return switch (result) {
      Ok(:final value) => [
          for (final row in value)
            if (row['slug'] != null && row['name'] != null)
              NicheOption(slug: row['slug']!, name: row['name']!),
        ],
      Err(:final failure) => throw failure,
    };
  }
}
