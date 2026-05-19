import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/category_data.dart';
import '../state/app_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(pinned: true, title: Text('Favorites')),
        if (app.favorites.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('No favorites yet. Star a conversion to save it.')),
          )
        else
          SliverList.separated(
            itemCount: app.favorites.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final f = app.favorites[i];
              final cat = categoryById(f.categoryId);
              final from = unitById(f.categoryId, f.fromUnitId);
              final to = unitById(f.categoryId, f.toUnitId);
              return ListTile(
                title: Text(cat?.title ?? f.categoryId),
                subtitle: Text('${from?.symbol ?? f.fromUnitId} → ${to?.symbol ?? f.toUnitId}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => app.removeFavorite(f),
                ),
                onTap: () => context.push(
                  '/convert/${f.categoryId}?from=${Uri.encodeComponent(f.fromUnitId)}&to=${Uri.encodeComponent(f.toUnitId)}',
                ),
              );
            },
          ),
      ],
    );
  }
}
