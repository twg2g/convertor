import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/category_data.dart';
import '../models/conversion_category.dart';
import '../state/app_state.dart';
import '../utils/format_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  IconData _iconFor(String name) => switch (name) {
        'payments' => Icons.payments_outlined,
        'straighten' => Icons.straighten,
        'scale' => Icons.scale_outlined,
        'thermostat' => Icons.thermostat_outlined,
        _ => Icons.category_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(pinned: true, title: Text('Universal Converter')),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          sliver: SliverToBoxAdapter(
            child: SearchBar(
              hintText: 'Search units or categories',
              leading: const Icon(Icons.search),
              readOnly: true,
              onTap: () => context.go('/search'),
            ),
          ),
        ),
        if (app.recents.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text('Recent', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  TextButton(onPressed: app.clearRecents, child: const Text('Clear')),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.separated(
              itemCount: app.recents.length.clamp(0, 8),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final r = app.recents[i];
                final cat = categoryById(r.categoryId);
                final from = unitById(r.categoryId, r.fromUnitId);
                final to = unitById(r.categoryId, r.toUnitId);
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: scheme.primaryContainer,
                      child: Text((cat?.title ?? '?').substring(0, 1)),
                    ),
                    title: Text(
                      '${formatConverted(r.inputValue, app.decimalPlaces)} ${from?.symbol ?? ''} → ${to?.symbol ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(formatConverted(r.result, app.decimalPlaces)),
                    onTap: () => context.push(
                      '/convert/${r.categoryId}?from=${Uri.encodeComponent(r.fromUnitId)}&to=${Uri.encodeComponent(r.toUnitId)}&v=${Uri.encodeComponent(r.inputValue.toString())}',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          sliver: SliverToBoxAdapter(child: Text('Categories', style: Theme.of(context).textTheme.titleMedium)),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final ConversionCategory c = categories[index];
                return Card(
                  child: InkWell(
                    onTap: () => context.push('/convert/${c.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(_iconFor(c.iconName), color: scheme.primary),
                          const Spacer(),
                          Text(c.title, style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: categories.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
