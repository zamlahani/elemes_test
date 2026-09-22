import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../services/tmdb_service.dart';
import '../widgets/error_view.dart';
import 'detail_screen.dart';
import 'search_screen.dart';
import 'watchlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _tabs = {
    'Popular': 'movie/popular',
    'Top Rated': 'movie/top_rated',
    'Upcoming': 'movie/upcoming',
    'Now Playing': 'movie/now_playing',
  };

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(const ['Movies', 'Search', 'Watchlist'][_index]),
          bottom: _index == 0
              ? TabBar(tabs: _tabs.keys.map((t) => Tab(text: t)).toList())
              : null,
        ),
        body: switch (_index) {
          0 => TabBarView(
              children: _tabs.values.map((endpoint) => _MovieList(endpoint: endpoint)).toList(),
            ),
          1 => const SearchScreen(),
          _ => const WatchlistScreen(),
        },
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Movies'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Watchlist'),
          ],
        ),
      ),
    );
  }
}

class _MovieList extends StatefulWidget {
  final String endpoint;
  const _MovieList({required this.endpoint});

  @override
  State<_MovieList> createState() => _MovieListState();
}

class _MovieListState extends State<_MovieList> {
  static const _prefetchThreshold = 5;

  final List<MediaItem> _movies = [];
  int _page = 1;
  bool _hasMore = true;
  bool _loading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    setState(() => _loading = true);
    try {
      final (movies, hasMore) = await TmdbService().fetchList(widget.endpoint, page: _page);
      if (!mounted) return;
      setState(() {
        _movies.addAll(movies);
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
    if (_movies.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_movies.isEmpty && _error != null) {
      return ErrorView(onRetry: _loadMore);
    }
    return ListView.builder(
      itemCount: _movies.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= _movies.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (_hasMore && !_loading && i == _movies.length - _prefetchThreshold) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _loadMore());
        }
        final movie = _movies[i];
        return ListTile(
          leading: movie.posterPath == null
              ? const Icon(Icons.movie)
              : Image.network(TmdbService.posterUrl(movie.posterPath), width: 48, fit: BoxFit.cover),
          title: Text(movie.title),
          subtitle: Text(movie.overview, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: Text(movie.voteAverage.toStringAsFixed(1)),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => DetailScreen(movie: movie)),
          ),
        );
      },
    );
  }
}
