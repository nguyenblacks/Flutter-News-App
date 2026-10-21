import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_news_app/config/constant_config.dart';
import 'package:flutter_news_app/feature/data/model/topheadlinesnews/top_headlines_news_response_model.dart';

abstract class NewsRemoteDataSource {
  /// Calls Google News RSS feed for the given category
  ///
  /// Throws a [DioException] for all error codes.
  Future<TopHeadlinesNewsResponseModel> getTopHeadlinesNews(String category);

  /// Calls Google News RSS feed for the given search query
  ///
  /// Throws a [DioException] for all error codes.
  Future<TopHeadlinesNewsResponseModel> searchTopHeadlinesNews(String keyword);
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final Dio dio;
  final ConstantConfig constantConfig;

  static const Map<String, String> _topicMap = {
    'business': 'BUSINESS',
    'entertainment': 'ENTERTAINMENT',
    'health': 'HEALTH',
    'science': 'SCIENCE',
    'sports': 'SPORTS',
    'sport': 'SPORTS',
    'technology': 'TECHNOLOGY',
  };

  static const Map<String, List<String>> _categoryImages = {
    'business': [
      'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800',
      'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?w=800',
      'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800',
      'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=800',
    ],
    'technology': [
      'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800',
      'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=800',
      'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800',
      'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=800',
    ],
    'entertainment': [
      'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800',
      'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
      'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800',
      'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800',
    ],
    'health': [
      'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=800',
      'https://images.unsplash.com/photo-1532938911079-1b06ac7ceec7?w=800',
      'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800',
      'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800',
    ],
    'science': [
      'https://images.unsplash.com/photo-1507668077129-56e32842fceb?w=800',
      'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=800',
      'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800',
      'https://images.unsplash.com/photo-1518152006812-edab29b069ac?w=800',
    ],
    'sports': [
      'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=800',
      'https://images.unsplash.com/photo-1517649763962-0c623266ddc0?w=800',
      'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=800',
      'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800',
    ],
    'general': [
      'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=800',
      'https://images.unsplash.com/photo-1495020689067-958852a7765e?w=800',
      'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?w=800',
      'https://images.unsplash.com/photo-1521295121783-8a321d551ad2?w=800',
    ],
  };

  NewsRemoteDataSourceImpl({
    required this.dio,
    required this.constantConfig,
  });

  @override
  Future<TopHeadlinesNewsResponseModel> getTopHeadlinesNews(String category) async {
    final catKey = category.toLowerCase().trim();
    String path;
    Map<String, dynamic>? queryParams;

    if (catKey == 'all' || catKey.isEmpty) {
      path = '/rss';
    } else if (_topicMap.containsKey(catKey)) {
      path = '/rss/headlines/section/topic/${_topicMap[catKey]}';
    } else {
      path = '/rss/search';
      queryParams = {'q': category};
    }

    final response = await dio.get(
      path,
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      return _parseGoogleNewsRss(response.data.toString(), catKey);
    } else {
      throw DioException(requestOptions: response.requestOptions);
    }
  }

  @override
  Future<TopHeadlinesNewsResponseModel> searchTopHeadlinesNews(String keyword) async {
    final response = await dio.get(
      '/rss/search',
      queryParameters: {'q': keyword},
    );

    if (response.statusCode == 200) {
      return _parseGoogleNewsRss(response.data.toString(), 'general');
    } else {
      throw DioException(requestOptions: response.requestOptions);
    }
  }

  TopHeadlinesNewsResponseModel _parseGoogleNewsRss(String xml, String category) {
    final items = <ItemArticleTopHeadlinesNewsResponseModel>[];
    final itemRegex = RegExp(r'<item>(.*?)</item>', dotAll: true);
    final titleRegex = RegExp(r'<title>(.*?)</title>', dotAll: true);
    final linkRegex = RegExp(r'<link>(.*?)</link>', dotAll: true);
    final pubDateRegex = RegExp(r'<pubDate>(.*?)</pubDate>', dotAll: true);
    final sourceRegex = RegExp(r'<source[^>]*url="([^"]*)"[^>]*>(.*?)</source>', dotAll: true);
    final mediaContentRegex = RegExp(r'<media:content[^>]*url="([^"]*)"', dotAll: true);
    final enclosureRegex = RegExp(r'<enclosure[^>]*url="([^"]*)"', dotAll: true);
    final imgRegex = RegExp(r'<img[^>]*src="([^"]*)"', dotAll: true);

    final catLower = category.toLowerCase();
    final imageList = _categoryImages[catLower] ?? _categoryImages['general']!;

    int index = 0;
    for (final match in itemRegex.allMatches(xml)) {
      final itemXml = match.group(1);
      if (itemXml == null) continue;

      String rawTitle = titleRegex.firstMatch(itemXml)?.group(1) ?? '';
      rawTitle = _cleanText(rawTitle);

      String link = linkRegex.firstMatch(itemXml)?.group(1) ?? '';
      link = _cleanText(link);

      String rawPubDate = pubDateRegex.firstMatch(itemXml)?.group(1) ?? '';
      String isoDate = _formatPubDateToIso(rawPubDate);

      final sourceMatch = sourceRegex.firstMatch(itemXml);
      String sourceName = sourceMatch != null ? _cleanText(sourceMatch.group(2) ?? '') : '';

      String title = rawTitle;
      if (sourceName.isNotEmpty && rawTitle.endsWith(' - $sourceName')) {
        title = rawTitle.substring(0, rawTitle.length - (' - $sourceName'.length)).trim();
      } else if (rawTitle.contains(' - ')) {
        final lastDash = rawTitle.lastIndexOf(' - ');
        if (sourceName.isEmpty) {
          sourceName = rawTitle.substring(lastDash + 3).trim();
        }
        title = rawTitle.substring(0, lastDash).trim();
      }

      if (sourceName.isEmpty) sourceName = 'Google News';

      // Check for image in media, enclosure or img tags
      String imageUrl = mediaContentRegex.firstMatch(itemXml)?.group(1) ??
          enclosureRegex.firstMatch(itemXml)?.group(1) ??
          imgRegex.firstMatch(itemXml)?.group(1) ??
          '';

      if (imageUrl.isEmpty) {
        imageUrl = imageList[index % imageList.length];
      }

      items.add(
        ItemArticleTopHeadlinesNewsResponseModel(
          source: ItemSourceTopHeadlinesNewsResponseModel(name: sourceName),
          author: sourceName,
          title: title,
          description: title,
          url: link,
          urlToImage: imageUrl,
          publishedAt: isoDate,
          content: title,
        ),
      );
      index++;
    }

    return TopHeadlinesNewsResponseModel(
      status: 'ok',
      totalResults: items.length,
      articles: items,
    );
  }

  String _cleanText(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#8216;', "'")
        .replaceAll('&#8217;', "'")
        .replaceAll('&#8220;', '"')
        .replaceAll('&#8221;', '"')
        .replaceAll('&#8211;', '-')
        .replaceAll('&#8212;', '-')
        .trim();
  }

  String _formatPubDateToIso(String pubDate) {
    try {
      final dt = HttpDate.parse(pubDate.trim());
      final iso = dt.toUtc().toIso8601String();
      if (iso.length >= 19) {
        return '${iso.substring(0, 19)}Z';
      }
    } catch (_) {}
    final nowIso = DateTime.now().toUtc().toIso8601String();
    return '${nowIso.substring(0, 19)}Z';
  }
}
