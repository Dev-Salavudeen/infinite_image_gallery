class AppConfig {
  static const pixabayBaseUrl = 'https://pixabay.com/api/';
  static const perPage = 24;
  static const attribution = 'Images provided by Pixabay';

  /// Pass at run/build time: `--dart-define=PIXABAY_API_KEY=your_key`
  static const pixabayApiKey = String.fromEnvironment('PIXABAY_API_KEY');

  static bool get hasApiKey => pixabayApiKey.isNotEmpty;
}

const pixabayCategories = <String>[
  'backgrounds',
  'fashion',
  'nature',
  'science',
  'education',
  'feelings',
  'health',
  'people',
  'religion',
  'places',
  'animals',
  'industry',
  'computer',
  'food',
  'sports',
  'transportation',
  'travel',
  'buildings',
  'business',
  'music',
];
