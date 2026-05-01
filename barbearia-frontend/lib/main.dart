import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'services/api_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Canal de alta importância (deve existir antes de qualquer notificação) ───
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'Agendamentos Klipper',
  description: 'Notificações de novos agendamentos',
  importance: Importance.max,
);

// Plugin global — acessado também em home_screen.dart
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// ─── HANDLER DE BACKGROUND ────────────────────────────────────────────────────
// OBRIGATÓRIO ser função top-level (fora de qualquer classe)
// Cuida de notificações quando o app está FECHADO ou em BACKGROUND
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final notification = message.notification;
  if (notification == null || kIsWeb) return;

  // Exibe a notificação local manualmente (necessário para mensagens data-only)
  await flutterLocalNotificationsPlugin.show(
    notification.hashCode,
    notification.title,
    notification.body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    ),
  );
}
// ─────────────────────────────────────────────────────────────────────────────

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Criar canal Android de alta importância
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // 2. Inicializar flutter_local_notifications (OBRIGATÓRIO para .show() funcionar)
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  // 3. Carregar variáveis de ambiente
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('[DotEnv] $e');
  }

  // 4. Inicializar Supabase
  try {
    await Supabase.initialize(
      url: dotenv.get('SUPABASE_URL',
          fallback: 'https://ocsykbqshxitgkpxgvzv.supabase.co'),
      anonKey: dotenv.get('SUPABASE_ANON_KEY', fallback: ''),
    );
  } catch (e) {
    debugPrint('[Supabase] $e');
  }

  // 5. Inicializar Firebase e registrar handler de background
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    try {
      await Firebase.initializeApp();

      // ✅ ESSENCIAL: registrar ANTES do runApp
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // ✅ Registra o token no Supabase para notificações push
      await NotificationService.registrarToken();

      // Solicitar permissão de notificações
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Garantir que notificações apareçam mesmo com app em foreground (iOS)
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('[Firebase] $e');
    }
  }

  runApp(const BarbeariaApp());
}

class BarbeariaApp extends StatelessWidget {
  const BarbeariaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiService()),
      ],
      child: MaterialApp(
        title: 'Klipper',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        scrollBehavior: MyCustomScrollBehavior(),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    await apiService.loadToken();
    await apiService.loadOnboardingStatus();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final apiService = Provider.of<ApiService>(context);
    if (!apiService.isAuthenticated) return const LoginScreen();
    if (!apiService.isOnboardingDone) return const OnboardingScreen();
    return const HomeScreen();
  }
}