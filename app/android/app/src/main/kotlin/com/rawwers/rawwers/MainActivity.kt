package com.rawwers.rawwers

import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity, not FlutterActivity: flutter_stripe presents its
// payment sheet and 3-D Secure challenge as Android fragments, which need a
// FragmentActivity host. With plain FlutterActivity the app builds and runs
// fine and then crashes the first time someone tries to pay - the worst place
// to find out, and invisible until that exact moment.
class MainActivity : FlutterFragmentActivity()
