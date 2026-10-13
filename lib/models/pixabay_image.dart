class PixabayImage {
  PixabayImage({
    required this.id,
    required this.pageUrl,
    required this.tags,
    required this.previewUrl,
    required this.webUrl,
    required this.largeUrl,
    required this.views,
    required this.downloads,
    required this.likes,
    required this.user,
    required this.userId,
    required this.width,
    required this.height,
    required this.previewW,
    required this.previewH,
  });

  final int id;
  final String pageUrl;
  final String tags;
  final String previewUrl;
  final String webUrl;
  final String largeUrl;
  final int views;
  final int downloads;
  final int likes;
  final String user;
  final int userId;
  final int width;
  final int height;
  final int previewW;
  final int previewH;

  String get thumb => webUrl.isNotEmpty ? webUrl : previewUrl;
  String get full => largeUrl.isNotEmpty ? largeUrl : webUrl;

  double get ratio {
    if (previewW == 0 || previewH == 0) return 1.2;
    return previewW / previewH;
  }

  List<String> get tagList {
    return tags
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pageURL': pageUrl,
        'tags': tags,
        'previewURL': previewUrl,
        'webformatURL': webUrl,
        'largeImageURL': largeUrl,
        'views': views,
        'downloads': downloads,
        'likes': likes,
        'user': user,
        'user_id': userId,
        'imageWidth': width,
        'imageHeight': height,
        'previewWidth': previewW,
        'previewHeight': previewH,
      };

  factory PixabayImage.fromJson(Map<String, dynamic> json) {
    return PixabayImage(
      id: json['id'] as int,
      pageUrl: json['pageURL'] as String? ?? '',
      tags: json['tags'] as String? ?? '',
      previewUrl: json['previewURL'] as String? ?? '',
      webUrl: json['webformatURL'] as String? ?? '',
      largeUrl: (json['largeImageURL'] as String?) ??
          json['webformatURL'] as String? ??
          '',
      views: json['views'] as int? ?? 0,
      downloads: json['downloads'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      user: json['user'] as String? ?? 'Unknown',
      userId: json['user_id'] as int? ?? 0,
      width: json['imageWidth'] as int? ?? 0,
      height: json['imageHeight'] as int? ?? 0,
      previewW: json['previewWidth'] as int? ?? json['webformatWidth'] as int? ?? 150,
      previewH: json['previewHeight'] as int? ?? json['webformatHeight'] as int? ?? 100,
    );
  }
}
