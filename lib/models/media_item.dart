enum MediaType { movie, tv, person }

MediaType _mediaTypeFromString(String? value) => switch (value) {
      'tv' => MediaType.tv,
      'person' => MediaType.person,
      _ => MediaType.movie,
    };

class MediaItem {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final double voteAverage;
  final MediaType mediaType;
  final String? date;

  MediaItem({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.backdropPath,
    required this.overview,
    required this.voteAverage,
    required this.mediaType,
    this.date,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json, {MediaType? mediaType}) {
    return MediaItem(
      id: json['id'] as int,
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      posterPath: json['poster_path'] as String? ?? json['profile_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      overview: json['overview'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      mediaType: json['media_type'] != null ? _mediaTypeFromString(json['media_type'] as String) : (mediaType ?? MediaType.movie),
      date: json['release_date'] as String? ?? json['first_air_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'poster_path': posterPath,
        'backdrop_path': backdropPath,
        'overview': overview,
        'vote_average': voteAverage,
        'media_type': mediaType.name,
        'release_date': date,
      };
}
