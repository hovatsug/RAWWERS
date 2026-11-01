import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'plugin_download_link.g.dart';

/// Opens the Lightroom plug-in's download link (Connect Lightroom's button).
///
/// A seam, like the payout links: the browser is a platform singleton a test
/// cannot drive.
abstract interface class PluginDownloadOpener {
  /// False when nothing could open [url].
  Future<bool> open(Uri url);
}

class BrowserPluginDownloadOpener implements PluginDownloadOpener {
  const BrowserPluginDownloadOpener();

  @override
  Future<bool> open(Uri url) async {
    try {
      // The browser itself, not an in-app view: a download needs somewhere to
      // go, and from there it can be shared to the Mac.
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } on Exception {
      return false;
    }
  }
}

@Riverpod(keepAlive: true)
PluginDownloadOpener pluginDownloadOpener(Ref ref) => const BrowserPluginDownloadOpener();
