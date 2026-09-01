import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/client.dart';
import '../../data/models/listing_card.dart';
import '../../data/repositories/listing_card_repository.dart';
import '../auth/providers.dart';

class ListingCardData {
  ListingCardData({required this.profile, required this.myNiches, required this.catalog, required this.publicProfile});

  final MyProProfileModel profile;
  final MyNichesModel myNiches;
  final List<NicheOption> catalog;
  final PublicProProfileModel publicProfile;
}

final listingCardRepositoryProvider = Provider<ListingCardRepository>((ref) {
  return ListingCardRepository(ref.watch(apiDioProvider));
});

final listingCardDataProvider = FutureProvider<ListingCardData>((ref) async {
  final repo = ref.read(listingCardRepositoryProvider);
  final me = ref.read(meProvider);
  if (me == null) {
    throw Exception('Not authenticated');
  }

  final results = await Future.wait([
    repo.getMyProfile(),
    repo.getMyNiches(),
    repo.listNiches(),
    repo.getPublicProfile(me.userId),
  ]);

  return ListingCardData(
    profile: results[0] as MyProProfileModel,
    myNiches: results[1] as MyNichesModel,
    catalog: results[2] as List<NicheOption>,
    publicProfile: results[3] as PublicProProfileModel,
  );
});
