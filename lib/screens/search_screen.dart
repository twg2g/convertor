import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/category_data.dart';
import '../models/conversion_category.dart';
import '../models/unit_definition.dart';

class _SearchHit {
  _SearchHit(this.category, this.unit);
  final ConversionCategory category;
  final UnitDefinition unit;
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() => _query = _controller.text.toLowerCase().trim()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_SearchHit> _hits() {
    final hits = <_SearchHit>[];
    for (final c in categories) {
      for (final u in unitsForCategory(c.id)) {
        if (_query.isEmpty || u.searchBlob.contains(_query) || c.title.toLowerCase().contains(_query)) {
          hits.add(_SearchHit(c, u));
        }
      }
    }
    return hits;
  }

  @override
  Widget build(BuildContext context) {
    final hits = _hits();
    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(pinned: true, title: Text('Search')),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          sliver: SliverToBoxAdapter(
            child: SearchBar(
              controller: _controller,
              hintText: 'Unit name, symbol, or category',
              leading: const Icon(Icons.search),
              trailing: [
                if (_query.isNotEmpty)
                  IconButton(icon: const Icon(Icons.clear), onPressed: _controller.clear),
              ],
            ),
          ),
        ),
        if (hits.isEmpty)
          const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('No matches')))
        else
          SliverList.separated(
            itemCount: hits.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final h = hits[i];
              final other = unitsForCategory(h.category.id).firstWhere((u) => u.id != h.unit.id);
              return ListTile(
                title: Text(h.unit.name),
                subtitle: Text('${h.category.title} · ${h.unit.symbol}'),
                onTap: () => context.push(
                  '/convert/${h.category.id}?from=${Uri.encodeComponent(h.unit.id)}&to=${Uri.encodeComponent(other.id)}',
                ),
              );
            },
          ),
      ],
    );
  }
}
