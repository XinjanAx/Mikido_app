import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/category_card_widget.dart';

class CategoryListScreen extends ConsumerWidget {
  final String tournamentId;

  const CategoryListScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoriesProvider(tournamentId));
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(categoriesProvider(tournamentId).notifier).load(),
          ),
        ],
      ),
      body: _buildBody(context, ref, state, isAdmin),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => context.push(
                '/tournaments/$tournamentId/categories/create',
              ),
              icon: const Icon(Icons.add),
              label: const Text('Nueva categoría'),
            )
          : null,
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    CategoriesState state,
    bool isAdmin,
  ) {
    if (state.isLoading && state.categories.isEmpty) {
      return const LoadingWidget(message: 'Cargando categorías...');
    }

    if (state.categories.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.category_outlined,
        title: 'Sin categorías',
        subtitle: isAdmin
            ? 'Crea las categorías del torneo (ej: Sub-12, Senior)'
            : 'Aún no hay categorías registradas',
        actionLabel: isAdmin ? 'Crear categoría' : null,
        onAction: isAdmin
            ? () => context.push(
                  '/tournaments/$tournamentId/categories/create',
                )
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(categoriesProvider(tournamentId).notifier).load(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 88),
        itemCount: state.categories.length,
        itemBuilder: (_, i) {
          final cat = state.categories[i];
          return CategoryCard(
            category: cat,
            isAdmin: isAdmin,
            onDelete: isAdmin
                ? () => _confirmDelete(context, ref, cat.id, cat.name)
                : null,
          );
        },
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, String id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text('¿Eliminar "$name"? Se borrarán los datos asociados.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(categoriesProvider(tournamentId).notifier)
                  .deleteCategory(id);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
