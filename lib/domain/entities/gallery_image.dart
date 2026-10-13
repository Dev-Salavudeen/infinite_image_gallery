class GalleryImage {
  const GalleryImage({
    required this.id,
    required this.pageUrl,
    required this.tags,
    required this.previewUrl,
    required this.webformatUrl,
    required this.largeImageUrl,
    required this.views,
    required this.downloads,
    required this.likes,
    required this.comments,
    required this.user,
    required this.userId,
    required this.userImageUrl,
    required this.imageWidth,
    required this.imageHeight,
    required this.previewWidth,
    required this.previewHeight,
    required this.type,
  });

  final int id;
  final String pageUrl;
  final String tags;
  final String previewUrl;
  final String webformatUrl;
  final String largeImageUrl;
  final int views;
  final int downloads;
  final int likes;
  final int comments;
  final String user;
  final int userId;
  final String userImageUrl;
  final int imageWidth;
  final int imageHeight;
  final int previewWidth;
  final int previewHeight;
  final String type;

  String get displayUrl =>
      largeImageUrl.isNotEmpty ? largeImageUrl : webformatUrl;

  String get thumbnailUrl =>
      webformatUrl.isNotEmpty ? webformatUrl : previewUrl;

  double get aspectRatio {
    if (previewWidth <= 0 || previewHeight <= 0) return 1;
    return previewWidth / previewHeight;
  }

  List<String> get tagList => tags
      .split(',')
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toList(growable: false);

  String get description {
    if (tags.trim().isEmpty) {
      return 'Untitled $type by $user';
    }
    return tags;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'pageURL': pageUrl,
    'tags': tags,
    'previewURL': previewUrl,
    'webformatURL': webformatUrl,
    'largeImageURL': largeImageUrl,
    'views': views,
    'downloads': downloads,
    'likes': likes,
    'comments': comments,
    'user': user,
    'user_id': userId,
    'userImageURL': userImageUrl,
    'imageWidth': imageWidth,
    'imageHeight': imageHeight,
    'previewWidth': previewWidth,
    'previewHeight': previewHeight,
    'type': type,
  };

  factory GalleryImage.fromMap(Map<String, dynamic> json) {
    return GalleryImage(
      id: json['id'] as int,
      pageUrl: json['pageURL'] as String? ?? '',
      tags: json['tags'] as String? ?? '',
      previewUrl: json['previewURL'] as String? ?? '',
      webformatUrl: json['webformatURL'] as String? ?? '',
      largeImageUrl:
          json['largeImageURL'] as String? ??
          json['webformatURL'] as String? ??
          '',
      views: json['views'] as int? ?? 0,
      downloads: json['downloads'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      user: json['user'] as String? ?? 'Unknown',
      userId: json['user_id'] as int? ?? 0,
      userImageUrl: json['userImageURL'] as String? ?? '',
      imageWidth: json['imageWidth'] as int? ?? 0,
      imageHeight: json['imageHeight'] as int? ?? 0,
      previewWidth:
          json['previewWidth'] as int? ?? json['webformatWidth'] as int? ?? 1,
      previewHeight:
          json['previewHeight'] as int? ?? json['webformatHeight'] as int? ?? 1,
      type: json['type'] as String? ?? 'photo',
    );
  }
}

class PagedImages {
  const PagedImages({
    required this.items,
    required this.totalHits,
    required this.page,
  });

  final List<GalleryImage> items;
  final int totalHits;
  final int page;
}
