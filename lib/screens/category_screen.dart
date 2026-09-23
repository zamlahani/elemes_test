import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../services/tmdb_service.dart';
import '../widgets/error_view.dart';
import '../widgets/movie_category_tabs.dart';
import '../widgets/movie_list_tile.dart';
import 'detail_screen.dart';

class CategoryScreen extends StatelessWidget {
  final Map<String, String>? tabs;
  final String? singleEndpoint;

  const CategoryScreen({super.key, this.tabs, this.singleEndpoint}) : assert(tabs != null || singleEndpoint != null);

  @override
  Widget build(BuildContext context) {
    if (tabs == null) {
      return _CategoryList(endpoint: singleEndpoint!);
    }
    return DefaultTabController(
      length: tabs!.length,
      child: Column(
        children: [
          MovieCategoryTabs(labels: tabs!.keys.toList()),
          Expanded(
            child: TabBarView(
              children: tabs!.values.map((endpoint) => _CategoryList(endpoint: endpoint)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryList extends StatefulWidget {
  final String endpoint;
  const _CategoryList({required this.endpoint});

  @override
  State<_CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<_CategoryList> with AutomaticKeepAliveClientMixin {
  static const _prefetchThreshold = 5;

  final List<MediaItem> _items = [];
  int _page = 1;
  bool _hasMore = true;
  bool _loading = false;
  Object? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _refresh() async {
    setState(() {
      _items.clear();
      _page = 1;
      _hasMore = true;
      _error = null;
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    setState(() => _loading = true);
    try {
      final (items, hasMore) = await TmdbService().fetchList(widget.endpoint, page: _page);
      if (!mounted) return;
      setState(() {
        _items.addAll(items);
        _hasMore = hasMore;
        _page++;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_items.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty && _error != null) {
      return ErrorView(onRetry: _loadMore);
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: movieGridDelegate,
        itemCount: _items.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i >= _items.length) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_hasMore && !_loading && i == _items.length - _prefetchThreshold) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _loadMore());
          }
          final item = _items[i];
          return MovieListTile(
            movie: item,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => DetailScreen(movie: item)),
            ),
          );
        },
      ),
    );
  }
}
