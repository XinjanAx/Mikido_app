import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/sync/sync_trigger_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'navigation/app_router.dart';

class TorneoApp extends ConsumerWidget {
  const TorneoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Activa el motor de sincronización offline (sync inicial + al recuperar
    // conexión). Ver core/sync/sync_trigger_provider.dart.
    ref.watch(syncTriggerProvider);
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Torneo MIKIDO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
