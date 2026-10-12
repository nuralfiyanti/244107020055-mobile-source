import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'pages/announcement_page.dart';
import 'pages/debug_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'messaging/push_service.dart';
import 'providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final container = ProviderContainer();
  await container.read(authStateProvider.future).catchError((_) => false);

  final router = buildRouter(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(router: router),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    // 1. Setup handler (background, local notif, permission, foreground, terminated)
    final initialRoute = await initializeMessageHandlers(
      onRoute: (route) => router.go(route),
    );

    await initFcmToken(
      onToken: (token) async {
        debugPrint('[FCM] Token: ${maskToken(token)}');
      },
    );

    if (initialRoute != null) router.go(initialRoute);
  });
}

GoRouter buildRouter(ProviderContainer container) {
  final refresh = ValueNotifier<int>(0);
  container.listen<AsyncValue<bool>>(
    authStateProvider,
    (_, _) => refresh.value++,
  );

  return GoRouter(
    refreshListenable: refresh,
    initialLocation: '/login',
    redirect: (context, state) {
      final loggedIn = container.read(authStateProvider).value ?? false;
      final goingLogin = state.matchedLocation == '/login';
      if (!loggedIn && !goingLogin) return '/login';
      if (loggedIn && goingLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/', builder: (_, _) => const HomePage()),
      GoRoute(path: '/debug', builder: (_, _) => const DebugPage()),
      GoRoute(
        path: '/pengumuman/:id',
        builder: (_, s) => AnnouncementPage(id: s.pathParameters['id'] ?? ''),
      ),
    ],
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router});
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Campus Notify',
      routerConfig: router,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
    );
  }
}