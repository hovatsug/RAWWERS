import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/pro_niche_input.dart';
import 'package:rawwers/api/models/pro_niche_view.dart';
import 'package:rawwers/api/models/update_my_niches_request.dart';
import 'package:rawwers/api/models/update_my_niches_response.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/features/pro/onboarding/onboarding_controller.dart';
import 'package:rawwers/features/pro/tier/tier_controller.dart';

part 'my_niches_controller.g.dart';

/// The photographer's own niches (GET /v1/pro/niches/mine), with the
/// fewest and most they may have.
///
/// Every change sends the whole list (PUT /v1/pro/me/niches) and the
/// server decides: the maximum, the minimum, exactly one main niche, and no
/// niche removed while a booking in it is not finished. A refusal comes
/// back as the server's own sentence, shown as it is.
@riverpod
class MyNichesController extends _$MyNichesController {
  @override
  Future<UpdateMyNichesResponse> build() async {
    final client = ref.read(proOnboardingClientProvider);
    final result = await apiCall(
      () => client.getMySelectedNichesV1ProNichesMineGet(authorization: null, xMinusUserMinusId: null),
    );
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  List<ProNicheView> get _current => state.valueOrNull?.niches ?? const [];

  String? get _main => state.valueOrNull?.primaryNicheSlug;

  /// Adds one niche from the active list. The first one is the main one.
  Future<String?> add(String slug) {
    final main = _main ?? slug;
    return _save([..._current.map((n) => n.slug), slug], main: main);
  }

  /// Removes one. The main niche goes only once another is the main one:
  /// said here, before asking the server, because the server's answer
  /// ("Choose your main niche") would not say which to choose.
  Future<String?> remove(String slug) {
    final others = _current.where((n) => n.slug != slug).toList();
    if (slug == _main && others.isNotEmpty) {
      return Future.value('This is your main niche. Make another niche your main one first, then remove this one.');
    }
    return _save([for (final n in others) n.slug], main: others.isEmpty ? null : _main);
  }

  Future<String?> makeMain(String slug) => _save([..._current.map((n) => n.slug)], main: slug);

  Future<String?> _save(List<String> slugs, {required String? main}) async {
    final levels = {for (final n in _current) n.slug: n.declaredLevel};
    final client = ref.read(proOnboardingClientProvider);
    final result = await apiCall(
      () => client.updateMyNichesV1ProMeNichesPut(
        requestBody: UpdateMyNichesRequest(
          primaryNicheSlug: main,
          niches: [
            for (final slug in slugs)
              ProNicheInput(slug: slug, declaredLevel: levels[slug], isPrimary: slug == main),
          ],
        ),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    switch (result) {
      case Ok(:final value):
        state = AsyncData(value);
        // The checklist's "What you shoot" and the dashboard's tier cards
        // read the same list.
        ref.invalidate(onboardingControllerProvider);
        ref.invalidate(tierStandingsControllerProvider);
        return null;
      case Err(:final failure):
        return switch (failure) {
          NetworkError() || Timeout() => 'Could not reach the server. Check your connection.',
          BusinessError(:final message) => message,
          _ => 'Could not save your niches.',
        };
    }
  }
}
