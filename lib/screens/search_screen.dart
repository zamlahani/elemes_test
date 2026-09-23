import 'dart:async';

import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../services/recent_search_service.dart';
import '../services/tmdb_service.dart';
import '../widgets/error_view.dart';
import '../widgets/movie_list_tile.dart';
import 'detail_screen.dart';

const _filterEndpoints = {
  null: 'search/multi',
  MediaType.movie: 'search/movie',
  MediaType.tv: 'search/tv',
  MediaType.person: 'search/person',
};

const _filterLabels = {
  null: 'All',
  MediaType.movie: 'Movies',
  MediaType.tv: 'TV',
  MediaType.person: 'People',
};

class SearchScreen extends StatefulWidget {
  final MediaType? initialType;
  const SearchScreen({super.key, this.initialType});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _prefetchThreshold = 5;

  final _controller = TextEditingController();
  Timer? _debounce;
  List<String> _recent = [];

  MediaType? _filter;
  String? _query;
  final List<MediaItem> _movies = [];
  int _page = 1;
  bool _hasMore = true;
  bool _loading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialType;
    RecentSearchService.getAll().then((v) {
      if (mounted) setState(() => _recent = v);
    });
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() => _query = null);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => _runSearch(query));
  }

  void _onFilterChanged(MediaType? filter) {
    setState(() => _filter = filter);
    final query = _query;
    if (query != null) _runSearch(query);
  }

  Future<void> _runSearch(String query) async {
    if (!mounted) return;
    _controller.text = query;
    await RecentSearchService.add(query);
    if (!mounted) return;
    final recent = await RecentSearchService.getAll();
    if (!mounted) return;
    setState(() {
      _recent = recent;
      _query = query;
      _movies.clear();
      _page = 1;
      _hasMore = true;
      _error = null;
    });
    _loadMore();
  }

  Future<void> _loadMore() async {
    final query = _query;
    if (query == null) return;
    final endpoint = _filterEndpoints[_filter]!;
    setState(() => _loading = true);
    try {
      final (movies, hasMore) = await TmdbService().fetchList(endpoint, page: _page, params: {'query': query});
      if (!mounted || query != _query) return;
      setState(() {
        _movies.addAll(movies);
        _hasMore = hasMore;
        _page++;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || query != _query) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Search...', border: InputBorder.none),
          onChanged: _onChanged,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                for (final filter in _filterLabels.keys)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_filterLabels[filter]!),
                      selected: _filter == filter,
                      onSelected: (_) => _onFilterChanged(filter),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_query == null) {
      if (_recent.isEmpty) {
        return const Center(child: Text('Type to search'));
      }
      return ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Recent searches', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          for (final query in _recent)
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(query),
              onTap: () => _runSearch(query),
            ),
        ],
      );
    }
    if (_movies.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_movies.isEmpty && _error != null) {
      return ErrorView(onRetry: _loadMore);
    }
    if (_movies.isEmpty) {
      return const Center(child: Text('No results'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: movieGridDelegate,
      itemCount: _movies.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= _movies.length) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_hasMore && !_loading && i == _movies.length - _prefetchThreshold) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _loadMore());
        }
        final movie = _movies[i];
        return MovieListTile(
          movie: movie,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => DetailScreen(movie: movie)),
          ),
        );
      },
    );
  }
}
