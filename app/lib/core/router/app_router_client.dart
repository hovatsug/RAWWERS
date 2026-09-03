import 'package:go_router/go_router.dart';
import 'package:rawwers/features/client/home/client_home_screen.dart';

/// Route paths for the client flavor. Kept as named constants rather than
/// string literals scattered through the app, so a typo in a path is a
/// compile error at the call site, not a runtime 404.
abstract final class ClientRoute {
  static const home = '/';
}

final clientRouter = GoRouter(
  initialLocation: ClientRoute.home,
  routes: [
    GoRoute(path: ClientRoute.home, builder: (context, state) => const ClientHomeScreen()),
  ],
);
