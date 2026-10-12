import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/device_repository.dart';
import '../messaging/push_service.dart';

final pushControllerProvider =
    NotifierProvider<PushController, PushState>(PushController.new);

class PushState {
  const PushState({
    this.permission = 'Belum diminta',
    this.maskedToken,
    this.logs = const [],
    this.started = false,
  });

  final String permission;
  final String? maskedToken;
  final List<String> logs;
  final bool started;

  PushState copyWith({
    String? permission,
    String? maskedToken,
    List<String>? logs,
    bool? started,
  }) {
    return PushState(
      permission: permission ?? this.permission,
      maskedToken: maskedToken ?? this.maskedToken,
      logs: logs ?? this.logs,
      started: started ?? this.started,
    );
  }
}

class PushController extends Notifier<PushState> {
  StreamSubscription<String>? _tokenSubscription;
  final DeviceRepository _deviceRepository = DeviceRepository();
  String? _fullToken;

  @override
  PushState build() {
    ref.onDispose(() => _tokenSubscription?.cancel());
    return const PushState();
  }

  Future<void> start() async {
    if (state.started) return;
    state = state.copyWith(started: true);

    final permission = await requestNotificationPermission();
    state = state.copyWith(
      permission: permission ? 'Diberikan' : 'Tidak diberikan',
    );
    _addLog(permission ? 'Izin notifikasi diberikan' : 'Izin notifikasi ditolak');

    _tokenSubscription = await initFcmToken(
      onToken: _handleToken,
      onTokenRefresh: (token) async {
        _addLog('onTokenRefresh');
        await _handleToken(token);
      },
      subscribeToTopic: (topic) async {
        await FirebaseMessaging.instance.subscribeToTopic(topic);
        _addLog('Berlangganan topik: $topic');
      },
    );
  }

  Future<void> resetToken() async {
    await FirebaseMessaging.instance.deleteToken();
    _addLog('Token di-reset, menunggu token baru');
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await _handleToken(token);
  }

  Future<void> unsubscribeFromCampusTopic() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('pengumuman-kampus');
    _addLog('Berhenti dari topik: pengumuman-kampus');
  }

  Future<void> copyToken() async {
    final token = _fullToken;
    if (token == null) return;
    await Clipboard.setData(ClipboardData(text: token));
    _addLog('Token disalin ke clipboard');
  }

  Future<void> _handleToken(String token) async {
    await _deviceRepository.registerToken(token);
    _fullToken = token;
    state = state.copyWith(maskedToken: maskToken(token));
    _addLog('Token diperbarui: ${maskToken(token)}');
  }

  void _addLog(String message) {
    final nextLogs = [...state.logs, message];
    state = state.copyWith(logs: nextLogs);
  }
}
