import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/client.dart';
import 'client_api.dart';

final clientApiProvider = Provider<ClientApi>((ref) {
  return ClientApi(ref.watch(apiDioProvider));
});
