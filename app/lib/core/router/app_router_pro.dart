import 'package:go_router/go_router.dart';
import 'package:rawwers/features/pro/home/pro_home_screen.dart';

/// Route paths for the pro flavor. Kept as named constants rather than
/// string literals scattered through the app, so a typo in a path is a
/// compile error at the call site, not a runtime 404.
abstract final class ProRoute {
  static const home = '/';
}

final proRouter = GoRouter(
  initialLocation: ProRoute.home,
  routes: [
    GoRoute(path: ProRoute.home, builder: (context, state) => const ProHomeScreen()),
  ],
);
