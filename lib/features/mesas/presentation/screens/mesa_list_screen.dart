import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/sync/sync_engine_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/mesa_entity.dart';
import '../providers/mesa_provider.dart';

/// Pantalla de inicio: lista de mesas. Cada mesa agrupa sus categorías.
class MesaListScreen extends ConsumerStatefulWidget {
  const MesaListScreen({super.key});

  @override
  ConsumerState<MesaListScreen> createState() => _MesaListScreenState();
}

class _MesaListScreenState extends ConsumerState<MesaListScreen> {
  static const _seenIntroKey = 'seen_offline_intro';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowIntro());
  }

  Future<void> _maybeShowIntro() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySeen = prefs.getBool(_seenIntroKey) ?? false;
    if (alreadySeen || !mounted) return;
    await prefs.setBool(_seenIntroKey, true);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¡Bienvenido!'),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                'assets/images/mikido_wordmark.png',
                height: 48,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'La primera vez inicia sesión con internet para verificar tu cuenta.\n\n'
              'Luego podrás usar la aplicación sin conexión y los cambios se '
              'sincronizarán automáticamente cuando haya internet.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuar...'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mesasAsync = ref.watch(mesasProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mesas'),
            if (user != null)
              Text('Hola, ${user.name}', style: AppTextStyles.bodySmall),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Sincronizar',
            onPressed: () => ref.read(syncEngineProvider).trySync(),
          ),
          IconButton(
            icon: Icon(ref.watch(themeModeProvider) == ThemeMode.dark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
            tooltip: 'Cambiar tema',
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.people_outline),
              tooltip: 'Participantes',
              onPressed: () => context.push(RouteConstants.players),
            ),
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              tooltip: 'Cerrar sesión',
              onPressed: () => _confirmLogout(context),
            )
          else
            IconButton(
              icon: const Icon(Icons.login_outlined),
              tooltip: 'Iniciar sesión',
              onPressed: () => context.push(RouteConstants.login),
            ),
        ],
      ),
      body: mesasAsync.when(
        loading: () => const LoadingWidget(message: 'Cargando mesas...'),
        error: (e, _) => Center(
          child: Text('$e', style: AppTextStyles.bodyMedium),
        ),
        data: (mesas) => _buildList(context, mesas, isAdmin),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => context.push(RouteConstants.mesaCreate),
              icon: const Icon(Icons.add),
              label: const Text('Nueva mesa'),
            )
          : null,
      // Versión fija al pie (el botón flotante queda por encima, sin taparla).
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Versión ${AppConstants.appVersion}',
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey400),
          ),
        ),
      ),
    );
  }

  Widget _buildList(
      BuildContext context, List<MesaEntity> mesas, bool isAdmin) {
    final orphanCount = ref.watch(categoriesByMesaProvider(null)).length;

    if (mesas.isEmpty && orphanCount == 0) {
      return EmptyStateWidget(
        icon: Icons.table_restaurant_outlined,
        title: 'Sin mesas',
        subtitle: isAdmin
            ? 'Crea la primera mesa (cancha, tatami, ring, pista...)'
            : 'Aún no hay mesas disponibles',
        actionLabel: isAdmin ? 'Crear mesa' : null,
        onAction:
            isAdmin ? () => context.push(RouteConstants.mesaCreate) : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(syncEngineProvider).trySync(),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 88),
        children: [
          for (final mesa in mesas)
            _MesaCard(
              title: mesa.name,
              subtitle: mesa.description,
              categoryCount:
                  ref.watch(categoriesByMesaProvider(mesa.id)).length,
              onTap: () => context
                  .push(RouteConstants.mesaDetail.replaceAll(':id', mesa.id)),
              onDelete: isAdmin ? () => _handleDelete(context, mesa) : null,
            ),
          // Categorías creadas antes de que existieran las mesas y que
          // todavía no tienen una asignada: se muestran aparte para que no
          // queden ocultas.
          if (orphanCount > 0)
            _MesaCard(
              title: 'Categorías sin mesa',
              subtitle: 'Creadas antes de que existieran las mesas',
              categoryCount: orphanCount,
              icon: Icons.help_outline,
              onTap: () => context.push(RouteConstants.mesaDetail
                  .replaceAll(':id', RouteConstants.noMesaId)),
            ),
        ],
      ),
    );
  }

  void _handleDelete(BuildContext context, MesaEntity mesa) {
    final hasCategories =
        ref.read(categoriesByMesaProvider(mesa.id)).isNotEmpty;
    if (hasCategories) {
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('No se puede eliminar'),
          content: const Text(
            'Esta mesa tiene categorías. Solo se puede eliminar una mesa '
            'vacía: primero elimina sus categorías.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar mesa'),
        content:
            Text('¿Eliminar "${mesa.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(dialogContext);
              final messenger = ScaffoldMessenger.of(context);
              final deleted =
                  await ref.read(mesaActionsProvider).delete(mesa.id);
              if (!deleted) {
                messenger.showSnackBar(const SnackBar(
                  content: Text(
                    'No se puede eliminar: la mesa tiene categorías en el '
                    'servidor. Sincroniza para verlas.',
                  ),
                  backgroundColor: AppColors.error,
                ));
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text(
          '¿Seguro que deseas cerrar sesión? Vas a necesitar conexión a '
          'internet para volver a iniciar sesión.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

class _MesaCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int categoryCount;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _MesaCard({
    required this.title,
    this.subtitle,
    required this.categoryCount,
    this.icon = Icons.table_restaurant_outlined,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Text(subtitle!,
                          style: AppTextStyles.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      categoryCount == 1
                          ? '1 categoría'
                          : '$categoryCount categorías',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.grey400),
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: AppColors.grey400, size: 20),
                  tooltip: 'Eliminar mesa',
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
