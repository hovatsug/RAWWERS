import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/client_api_provider.dart';
import '../../design/tokens.dart';
import '../../design/widgets/r_button.dart';
import '../../design/widgets/r_card.dart';
import '../../design/widgets/r_skeleton.dart';
import '../../design/widgets/r_text_field.dart';

class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ref.read(clientApiProvider).clientDiscover({'limit': 20});
    if (!mounted) return;
    if (!result.ok) {
      setState(() {
        _loading = false;
        _error = result.error?.message ?? 'Failed to load home';
      });
      return;
    }
    setState(() {
      _loading = false;
      _items = (result.data?['items'] as List<dynamic>?) ?? const [];
    });
    await ref.read(clientApiProvider).track('client_home_viewed', {'source': 'flutter'});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const RSkeleton(height: 120);
    if (_error != null) {
      return RCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_error!, style: const TextStyle(color: RTokens.statusDanger)), TextButton(onPressed: _load, child: const Text('Retry'))]),
      );
    }
    if (_items.isEmpty) {
      return const RCard(child: Text('No recommendations yet.'));
    }

    return ListView(
      children: [
        const Text('Home', style: TextStyle(fontSize: RTokens.textXl, fontWeight: FontWeight.w700)),
        const SizedBox(height: RTokens.spacingX3),
        ..._items.take(10).map((item) {
          final m = (item as Map).cast<String, dynamic>();
          final id = (m['pro_user_id'] ?? m['id'] ?? '').toString();
          return Padding(
            padding: const EdgeInsets.only(bottom: RTokens.spacingX3),
            child: RCard(
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(m.toString(), maxLines: 3, overflow: TextOverflow.ellipsis)),
                if (id.isNotEmpty) TextButton(onPressed: () => context.go('/pros/$id'), child: const Text('Open')),
              ]),
            ),
          );
        }),
      ],
    );
  }
}

class ClientSearchScreen extends ConsumerStatefulWidget {
  const ClientSearchScreen({super.key});

  @override
  ConsumerState<ClientSearchScreen> createState() => _ClientSearchScreenState();
}

class _ClientSearchScreenState extends ConsumerState<ClientSearchScreen> {
  final _q = TextEditingController();
  final _city = TextEditingController();
  bool _loading = false;
  String? _error;
  List<dynamic> _items = const [];

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ref.read(clientApiProvider).searchPros({'q': _q.text.trim(), 'city': _city.text.trim(), 'limit': 30});
    if (!mounted) return;
    if (!result.ok) {
      setState(() {
        _loading = false;
        _error = result.error?.message ?? 'Search failed';
      });
      return;
    }
    setState(() {
      _loading = false;
      _items = (result.data?['items'] as List<dynamic>?) ?? const [];
    });
    await ref.read(clientApiProvider).track('client_search_viewed', {'source': 'flutter', 'q': _q.text.trim(), 'city': _city.text.trim()});
  }

  @override
  void dispose() {
    _q.dispose();
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Text('Search', style: TextStyle(fontSize: RTokens.textXl, fontWeight: FontWeight.w700)),
        const SizedBox(height: RTokens.spacingX3),
        RCard(
          child: Column(children: [
            RTextField(controller: _q, hintText: 'Search'),
            const SizedBox(height: RTokens.spacingX2),
            RTextField(controller: _city, hintText: 'City'),
            const SizedBox(height: RTokens.spacingX2),
            RButton(label: _loading ? 'Searching...' : 'Search', onPressed: _loading ? null : _search),
          ]),
        ),
        if (_error != null) ...[
          const SizedBox(height: RTokens.spacingX2),
          Text(_error!, style: const TextStyle(color: RTokens.statusDanger)),
        ],
        const SizedBox(height: RTokens.spacingX3),
        ..._items.map((e) {
          final m = (e as Map).cast<String, dynamic>();
          final id = (m['id'] ?? '').toString();
          return Padding(
            padding: const EdgeInsets.only(bottom: RTokens.spacingX2),
            child: RCard(
              child: ListTile(
                title: Text(m['display_name']?.toString() ?? id),
                subtitle: Text(m['headline']?.toString() ?? '-'),
                trailing: id.isNotEmpty ? TextButton(onPressed: () => context.go('/pros/$id'), child: const Text('Open')) : null,
              ),
            ),
          );
        }),
      ],
    );
  }
}

class ClientBookingsScreen extends StatelessWidget {
  const ClientBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Text('Bookings', style: TextStyle(fontSize: RTokens.textXl, fontWeight: FontWeight.w700)),
        const SizedBox(height: RTokens.spacingX3),
        const RCard(child: Text('List endpoint unavailable in catalog. Open by booking ID.')),
        const SizedBox(height: RTokens.spacingX2),
        RCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Use details route:'),
            const SizedBox(height: RTokens.spacingX1),
            TextButton(onPressed: () => context.go('/bookings/demo-booking-id'), child: const Text('Open sample booking route')),
          ]),
        ),
      ],
    );
  }
}

class ClientBookingDetailScreen extends ConsumerStatefulWidget {
  const ClientBookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<ClientBookingDetailScreen> createState() => _ClientBookingDetailScreenState();
}

class _ClientBookingDetailScreenState extends ConsumerState<ClientBookingDetailScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _booking;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ref.read(clientApiProvider).getClientBooking(widget.bookingId);
    if (!mounted) return;
    if (!result.ok) {
      setState(() {
        _loading = false;
        _error = result.error?.message ?? 'Booking unavailable';
      });
      return;
    }
    setState(() {
      _loading = false;
      _booking = result.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const RSkeleton(height: 120);
    if (_error != null) return RCard(child: Text(_error!, style: const TextStyle(color: RTokens.statusDanger)));
    return ListView(children: [RCard(child: Text(const JsonEncoder.withIndent('  ').convert(_booking)))]);
  }
}

class ClientNotificationsScreen extends ConsumerStatefulWidget {
  const ClientNotificationsScreen({super.key});

  @override
  ConsumerState<ClientNotificationsScreen> createState() => _ClientNotificationsScreenState();
}

class _ClientNotificationsScreenState extends ConsumerState<ClientNotificationsScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ref.read(clientApiProvider).listNotifications({'limit': 50});
    if (!mounted) return;
    if (!result.ok) {
      setState(() {
        _loading = false;
        _error = result.error?.message ?? 'Notifications unavailable';
      });
      return;
    }
    setState(() {
      _loading = false;
      _items = (result.data?['items'] as List<dynamic>?) ?? const [];
    });
    await ref.read(clientApiProvider).track('client_notifications_viewed', {'source': 'flutter'});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const RSkeleton(height: 120);
    if (_error != null) return RCard(child: Text(_error!, style: const TextStyle(color: RTokens.statusDanger)));
    if (_items.isEmpty) return const RCard(child: Text('No notifications'));
    return ListView(children: _items.map((e) => Padding(padding: const EdgeInsets.only(bottom: RTokens.spacingX2), child: RCard(child: Text((e as Map).toString())))).toList());
  }
}

class ClientRewardsScreen extends ConsumerStatefulWidget {
  const ClientRewardsScreen({super.key});

  @override
  ConsumerState<ClientRewardsScreen> createState() => _ClientRewardsScreenState();
}

class _ClientRewardsScreenState extends ConsumerState<ClientRewardsScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _balance = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ref.read(clientApiProvider).rewardsBalance();
    if (!mounted) return;
    if (!result.ok) {
      setState(() {
        _loading = false;
        _error = result.error?.message ?? 'Rewards unavailable';
      });
      return;
    }
    setState(() {
      _loading = false;
      _balance = result.data ?? {};
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const RSkeleton(height: 100);
    if (_error != null) return RCard(child: Text(_error!, style: const TextStyle(color: RTokens.statusDanger)));
    return ListView(children: [RCard(child: Text(_balance.toString()))]);
  }
}

class ClientSettingsScreen extends ConsumerStatefulWidget {
  const ClientSettingsScreen({super.key});

  @override
  ConsumerState<ClientSettingsScreen> createState() => _ClientSettingsScreenState();
}

class _ClientSettingsScreenState extends ConsumerState<ClientSettingsScreen> {
  final _contactJson = TextEditingController(text: '{}');
  String? _message;

  Future<void> _save() async {
    final payload = (jsonDecode(_contactJson.text) as Map).cast<String, dynamic>();
    final result = await ref.read(clientApiProvider).putContact(payload);
    setState(() {
      _message = result.ok ? 'Saved' : (result.error?.message ?? 'Save failed');
    });
  }

  @override
  void dispose() {
    _contactJson.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      const Text('Settings', style: TextStyle(fontSize: RTokens.textXl, fontWeight: FontWeight.w700)),
      const SizedBox(height: RTokens.spacingX3),
      RCard(child: Column(children: [RTextField(controller: _contactJson, maxLines: 4), const SizedBox(height: RTokens.spacingX2), RButton(label: 'Save contact', onPressed: _save), if (_message != null) Text(_message!) ])),
    ]);
  }
}

class ClientWaitlistScreen extends ConsumerStatefulWidget {
  const ClientWaitlistScreen({super.key});

  @override
  ConsumerState<ClientWaitlistScreen> createState() => _ClientWaitlistScreenState();
}

class _ClientWaitlistScreenState extends ConsumerState<ClientWaitlistScreen> {
  final _email = TextEditingController();
  final _city = TextEditingController();
  String? _message;

  Future<void> _join() async {
    final result = await ref.read(clientApiProvider).joinWaitlist({'email': _email.text.trim(), 'city': _city.text.trim()});
    setState(() {
      _message = result.ok ? 'Joined waitlist' : (result.error?.message ?? 'Failed');
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      const Text('Waitlist', style: TextStyle(fontSize: RTokens.textXl, fontWeight: FontWeight.w700)),
      const SizedBox(height: RTokens.spacingX3),
      RCard(child: Column(children: [RTextField(controller: _email, hintText: 'Email'), const SizedBox(height: RTokens.spacingX2), RTextField(controller: _city, hintText: 'City'), const SizedBox(height: RTokens.spacingX2), RButton(label: 'Join waitlist', onPressed: _join), if (_message != null) Text(_message!)])),
    ]);
  }
}

class ClientDisputesScreen extends ConsumerStatefulWidget {
  const ClientDisputesScreen({super.key});

  @override
  ConsumerState<ClientDisputesScreen> createState() => _ClientDisputesScreenState();
}

class _ClientDisputesScreenState extends ConsumerState<ClientDisputesScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ref.read(clientApiProvider).listDisputes({'limit': 30});
    if (!mounted) return;
    if (!result.ok) {
      setState(() {
        _loading = false;
        _error = result.error?.message ?? 'Disputes unavailable';
      });
      return;
    }
    setState(() {
      _loading = false;
      _items = (result.data?['items'] as List<dynamic>?) ?? const [];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const RSkeleton(height: 120);
    if (_error != null) return RCard(child: Text(_error!, style: const TextStyle(color: RTokens.statusDanger)));
    if (_items.isEmpty) return const RCard(child: Text('No disputes'));
    return ListView(children: _items.map((e) => Padding(padding: const EdgeInsets.only(bottom: RTokens.spacingX2), child: RCard(child: Text((e as Map).toString())))).toList());
  }
}

class ClientGigScreen extends ConsumerStatefulWidget {
  const ClientGigScreen({super.key, required this.gigId});

  final String gigId;

  @override
  ConsumerState<ClientGigScreen> createState() => _ClientGigScreenState();
}

class _ClientGigScreenState extends ConsumerState<ClientGigScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _gig;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ref.read(clientApiProvider).getGig(widget.gigId);
    if (!mounted) return;
    if (!result.ok) {
      setState(() {
        _loading = false;
        _error = result.error?.message ?? 'Gig unavailable';
      });
      return;
    }
    setState(() {
      _loading = false;
      _gig = result.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const RSkeleton(height: 120);
    if (_error != null) return RCard(child: Text(_error!, style: const TextStyle(color: RTokens.statusDanger)));
    final galleryId = (_gig?['gallery_id'] ?? _gig?['proof_gallery_id'] ?? '').toString();
    return ListView(children: [
      RCard(child: Text(const JsonEncoder.withIndent('  ').convert(_gig))),
      if (galleryId.isNotEmpty) TextButton(onPressed: () => context.go('/gigs/${widget.gigId}/gallery/$galleryId'), child: const Text('Open gallery')),
    ]);
  }
}

class ClientGalleryScreen extends ConsumerStatefulWidget {
  const ClientGalleryScreen({super.key, required this.galleryId});

  final String galleryId;

  @override
  ConsumerState<ClientGalleryScreen> createState() => _ClientGalleryScreenState();
}

class _ClientGalleryScreenState extends ConsumerState<ClientGalleryScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _gallery;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ref.read(clientApiProvider).getProofGallery(widget.galleryId);
    if (!mounted) return;
    if (!result.ok) {
      setState(() {
        _loading = false;
        _error = result.error?.message ?? 'Gallery unavailable';
      });
      return;
    }
    setState(() {
      _loading = false;
      _gallery = result.data;
    });
  }

  Future<void> _saveSelection() async {
    await ref.read(clientApiProvider).saveSelection(widget.galleryId, {'items': []});
  }

  Future<void> _submitSelection() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RTokens.spacingX4),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Submit final selection?', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: RTokens.spacingX2),
            RButton(label: 'Confirm', onPressed: () => Navigator.of(context).pop(true)),
          ]),
        ),
      ),
    );
    if (ok != true) return;
    await ref.read(clientApiProvider).submitSelection(widget.galleryId, {'finalize': true});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const RSkeleton(height: 120);
    if (_error != null) return RCard(child: Text(_error!, style: const TextStyle(color: RTokens.statusDanger)));
    return ListView(children: [
      RCard(child: Text(const JsonEncoder.withIndent('  ').convert(_gallery))),
      const SizedBox(height: RTokens.spacingX2),
      RButton(label: 'Save selection', variant: RButtonVariant.secondary, onPressed: _saveSelection),
      const SizedBox(height: RTokens.spacingX2),
      RButton(label: 'Submit selection', onPressed: _submitSelection),
    ]);
  }
}

class ClientDeliveryScreen extends ConsumerStatefulWidget {
  const ClientDeliveryScreen({super.key, required this.gigId});

  final String gigId;

  @override
  ConsumerState<ClientDeliveryScreen> createState() => _ClientDeliveryScreenState();
}

class _ClientDeliveryScreenState extends ConsumerState<ClientDeliveryScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _media;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ref.read(clientApiProvider).listGigMedia(widget.gigId);
    if (!mounted) return;
    if (!result.ok) {
      setState(() {
        _loading = false;
        _error = result.error?.message ?? 'Delivery unavailable';
      });
      return;
    }
    setState(() {
      _loading = false;
      _media = result.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const RSkeleton(height: 120);
    if (_error != null) return RCard(child: Text(_error!, style: const TextStyle(color: RTokens.statusDanger)));
    return ListView(children: [RCard(child: Text(const JsonEncoder.withIndent('  ').convert(_media)))]);
  }
}
