import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static Future<void> registrarToken() async {
    try {
      // Garante permissão antes de pedir token
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('[FCM] Status permissão: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('[FCM] Permissão negada — token não será registrado.');
        return;
      }

      // Aguarda token com timeout
      final token = await FirebaseMessaging.instance.getToken()
          .timeout(const Duration(seconds: 10));

      debugPrint('[FCM] Token obtido: $token');

      if (token == null) {
        debugPrint('[FCM] Token nulo — Firebase pode não ter inicializado.');
        return;
      }

      await Supabase.instance.client
          .from('push_tokens')
          .upsert(
            {'token': token, 'updated_at': DateTime.now().toIso8601String()},
            onConflict: 'token',
          );

      debugPrint('[FCM] ✅ Token registrado no Supabase: ${token.substring(0, 20)}...');

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        Supabase.instance.client.from('push_tokens').upsert(
          {'token': newToken, 'updated_at': DateTime.now().toIso8601String()},
          onConflict: 'token',
        );
        debugPrint('[FCM] Token renovado: ${newToken.substring(0, 20)}...');
      });

    } catch (e) {
      debugPrint('[FCM] ❌ Erro ao registrar token: $e');
    }
  }

  static void configurarHandlers(FlutterLocalNotificationsPlugin plugin) {
    // iOS: foreground notifications need to be handled with a local display
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) async {
      debugPrint('[FCM] Foreground: ${msg.notification?.title}');
      // Exibe notificação local para iOS foreground (no silent data-only messages)
      if (msg.notification != null && !kIsWeb) {
        await plugin.show(
          msg.notification!.hashCode,
          msg.notification!.title,
          msg.notification!.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'Agendamentos Klipper',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
      debugPrint('[FCM] onMessageOpenedApp: ${msg.data}');
    });
  }

  static Future<bool> solicitarPermissao() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }
}