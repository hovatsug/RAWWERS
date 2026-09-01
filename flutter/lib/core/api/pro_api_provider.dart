import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/client.dart';
import 'pro_api.dart';

final proApiProvider = Provider<ProApi>((ref) {
  return ProApi(ref.watch(apiDioProvider));
});
