import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app.dart';
import 'core/constants/supabase_constants.dart';
import 'features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ⚠️ Solo para desarrollo — eliminar en producción
class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⚠️ Solo desarrollo
  HttpOverrides.global = _DevHttpOverrides();

  // Inicializar zonas horarias para notificaciones
  tz.initializeTimeZones();

  // Inicializar notificaciones locales
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  final notificationDs = NotificationLocalDataSource(notificationsPlugin);
  await notificationDs.initialize();
  await notificationDs.requestPermissions();

  // Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    // ignore: deprecated_member_use
    anonKey: SupabaseConstants.supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: TorneoApp(),
    ),
  );
}