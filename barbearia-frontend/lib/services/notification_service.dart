// lib/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  /// Registra o token FCM no Supabase (tabela push_tokens)
  static Future<void> registrarToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    await Supabase.instance.client
        .from('push_tokens')
        .upsert(
          {'token': token, 'updated_at': DateTime.now().toIso8601String()},
          onConflict: 'token',
        );

    // Renovação automática de token
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      Supabase.instance.client.from('push_tokens').upsert(
        {'token': newToken, 'updated_at': DateTime.now().toIso8601String()},
        onConflict: 'token',
      );
    });

    debugPrint('[FCM] Token registrado: $token');
  }

  /// Configura handlers para mensagens em foreground
  static void configurarHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      debugPrint('[FCM] Foreground: ${msg.notification?.title} — ${msg.notification?.body}');
      // TODO: mostrar SnackBar ou atualizar badge
    });

    // Handler para quando usuário toca notificação e app está em background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
      debugPrint('[FCM] onMessageOpenedApp: ${msg.data}');
    });
  }

  /// Solicita permissão de notificações (iOS/Android)
  static Future<bool> solicitarPermissao() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }
}