// Settings > Connect Lightroom: a one-time code for the Lightroom Classic
// plug-in, and the connected devices with Revoke.
//
// What matters: the code is shown large, with how long it lasts and where to
// type it; asking again replaces it; each device shows its name and last use;
// Revoke asks first, then calls the server and the device leaves the list;
// the screen is reachable from Settings (pro_settings_screen_test.dart).
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/api_client/lightroom_client.dart';
import 'package:rawwers/api/models/delivery_device_view.dart';
import 'package:rawwers/api/models/delivery_devices_response.dart';
import 'package:rawwers/api/models/pairing_code_response.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/lightroom/connect_lightroom_controller.dart';
import 'package:rawwers/features/pro/lightroom/connect_lightroom_screen.dart';
import 'package:retrofit/retrofit.dart';

DeliveryDeviceView _device(String id, String name) => DeliveryDeviceView(
      id: id,
      deviceName: name,
      tokenPrefix: 'rwd_Ab$id',
      pluginVersion: '1.0.0',
      createdAt: DateTime.utc(2026, 10, 1, 9),
      lastUsedAt: DateTime.utc(2026, 10, 30, 21, 5),
    );

/// The server, as the generated client sees it.
class _FakeClient implements LightroomClient {
  _FakeClient(this.devices);

  List<DeliveryDeviceView> devices;
  int codesIssued = 0;
  final revoked = <String>[];
  int? revokeStatus;

  Response<T> _ok<T>(T data) => Response<T>(data: data, statusCode: 200, requestOptions: RequestOptions());

  @override
  Future<HttpResponse<PairingCodeResponse>> createPairingCodeV1ProLightroomPairingCodePost({
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? extras,
  }) async {
    codesIssued++;
    final code = PairingCodeResponse(
      code: codesIssued == 1 ? 'ABCD-EFGH' : 'JKMN-PQRS',
      expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      validMinutes: 10,
    );
    return HttpResponse(code, _ok(code));
  }

  @override
  Future<HttpResponse<DeliveryDevicesResponse>> listDevicesV1ProLightroomDevicesGet({
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? extras,
  }) async {
    final body = DeliveryDevicesResponse(items: List.of(devices), maxDevices: 3);
    return HttpResponse(body, _ok(body));
  }

  @override
  Future<HttpResponse<dynamic>> revokeDeviceV1ProLightroomDevicesDeviceIdDelete({
    required String deviceId,
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? extras,
  }) async {
    revoked.add(deviceId);
    if (revokeStatus != null) {
      throw DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.badResponse,
        response: Response(statusCode: revokeStatus, requestOptions: RequestOptions(), data: {
          'error': {'code': 'boom', 'message': 'The server could not revoke it.'},
        }),
      );
    }
    devices = devices.where((d) => d.id != deviceId).toList();
    return HttpResponse<dynamic>(null, _ok<dynamic>(null));
  }
}

Future<_FakeClient> _pump(WidgetTester tester, {List<DeliveryDeviceView>? devices}) async {
  final client = _FakeClient(devices ?? [_device('1', 'Studio iMac'), _device('2', 'MacBook Pro')]);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [lightroomClientProvider.overrideWithValue(client)],
      child: MaterialApp(theme: buildProTheme(), home: const ConnectLightroomScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return client;
}

void main() {
  testWidgets('a code is shown large, with how long it lasts and where to type it', (tester) async {
    final client = await _pump(tester);
    expect(find.byKey(const ValueKey('pairing-code')), findsNothing);

    await tester.tap(find.text('Get a pairing code'));
    await tester.pumpAndSettle();

    expect(client.codesIssued, 1);
    expect(find.text('ABCD-EFGH'), findsOneWidget);
    expect(find.textContaining('It works once, until'), findsOneWidget);
    expect(find.textContaining('(10 minutes)'), findsOneWidget);
    expect(find.textContaining('Export dialog'), findsOneWidget);
  });

  testWidgets('asking again replaces the code', (tester) async {
    final client = await _pump(tester);
    await tester.tap(find.text('Get a pairing code'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get a new code'));
    await tester.pumpAndSettle();

    expect(client.codesIssued, 2);
    expect(find.text('JKMN-PQRS'), findsOneWidget);
    expect(find.text('ABCD-EFGH'), findsNothing);
  });

  testWidgets('each connected device shows its name, last use and version', (tester) async {
    await _pump(tester);
    expect(find.text('Studio iMac'), findsOneWidget);
    expect(find.text('MacBook Pro'), findsOneWidget);
    expect(find.textContaining('Last used'), findsNWidgets(2));
    expect(find.textContaining('plug-in 1.0.0'), findsNWidgets(2));
    expect(find.textContaining('Up to 3 devices'), findsOneWidget);
  });

  testWidgets('no devices says so', (tester) async {
    await _pump(tester, devices: const []);
    expect(find.text('No device is connected yet.'), findsOneWidget);
  });

  testWidgets('revoking asks first; keeping changes nothing', (tester) async {
    final client = await _pump(tester);
    await tester.tap(find.text('Revoke').first);
    await tester.pumpAndSettle();
    expect(find.text('Revoke Studio iMac?'), findsOneWidget);

    await tester.tap(find.text('Keep'));
    await tester.pumpAndSettle();
    expect(client.revoked, isEmpty);
    expect(find.text('Studio iMac'), findsOneWidget);
  });

  testWidgets('revoking calls the server and the device leaves the list', (tester) async {
    final client = await _pump(tester);
    await tester.tap(find.text('Revoke').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Revoke'));
    await tester.pumpAndSettle();

    expect(client.revoked, ['1']);
    expect(find.text('Studio iMac'), findsNothing);
    expect(find.text('MacBook Pro'), findsOneWidget);
    expect(find.text('Studio iMac was revoked.'), findsOneWidget);
  });

  testWidgets('a revoke the server refuses says so and keeps the device', (tester) async {
    final client = await _pump(tester);
    client.revokeStatus = 500;
    await tester.tap(find.text('Revoke').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Revoke'));
    await tester.pumpAndSettle();

    expect(find.text('Studio iMac'), findsOneWidget);
    expect(find.textContaining('revoked'), findsNothing);
  });

  test('a device already gone counts as revoked', () async {
    final client = _FakeClient([_device('1', 'Studio iMac')])..revokeStatus = 404;
    final container = ProviderContainer(overrides: [lightroomClientProvider.overrideWithValue(client)]);
    addTearDown(container.dispose);
    await container.read(lightroomDevicesControllerProvider.future);

    final problem = await container.read(lightroomDevicesControllerProvider.notifier).revoke('1');

    expect(problem, isNull);
  });
}
