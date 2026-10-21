import 'package:equatable/equatable.dart';

class TopHeadlinesNewsResponseModel extends Equatable {
  final String status;
  final int totalResults;
  final List<ItemArticleTopHeadlinesNewsResponseModel> articles;

  const TopHeadlinesNewsResponseModel({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory TopHeadlinesNewsResponseModel.fromJson(Map<String, dynamic> json) {
    return TopHeadlinesNewsResponseModel(
      status: json['status'] as String? ?? 'ok',
      totalResults: json['totalResults'] as int? ?? 0,
      articles: (json['articles'] as List<dynamic>?)
              ?.map((e) => ItemArticleTopHeadlinesNewsResponseModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'totalResults': totalResults,
      'articles': articles.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [status, totalResults, articles];

  @override
  String toString() {
    return 'TopHeadlinesNewsResponseModel{status: $status, totalResults: $totalResults, articles: $articles}';
  }
}

class ItemArticleTopHeadlinesNewsResponseModel extends Equatable {
  final ItemSourceTopHeadlinesNewsResponseModel source;
  final String? author;
  final String title;
  final String? description;
  final String url;
  final String urlToImage;
  final String publishedAt;
  final String? content;

  const ItemArticleTopHeadlinesNewsResponseModel({
    required this.source,
    this.author,
    required this.title,
    this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    this.content,
  });

  factory ItemArticleTopHeadlinesNewsResponseModel.fromJson(Map<String, dynamic> json) {
    return ItemArticleTopHeadlinesNewsResponseModel(
      source: json['source'] != null
          ? ItemSourceTopHeadlinesNewsResponseModel.fromJson(
              json['source'] as Map<String, dynamic>)
          : const ItemSourceTopHeadlinesNewsResponseModel(name: ''),
      author: json['author'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      url: json['url'] as String? ?? '',
      urlToImage: json['urlToImage'] as String? ?? '',
      publishedAt: json['publishedAt'] as String? ?? '',
      content: json['content'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source.toJson(),
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'content': content,
    };
  }

  @override
  List<Object?> get props => [source, author, title, description, url, urlToImage, publishedAt, content];

  @override
  String toString() {
    return 'ItemArticleTopHeadlinesNewsResponseModel{source: $source, author: $author, title: $title, description: $description, url: $url, urlToImage: $urlToImage, publishedAt: $publishedAt, content: $content}';
  }
}

class ItemSourceTopHeadlinesNewsResponseModel extends Equatable {
  final String name;

  const ItemSourceTopHeadlinesNewsResponseModel({required this.name});

  factory ItemSourceTopHeadlinesNewsResponseModel.fromJson(Map<String, dynamic> json) {
    return ItemSourceTopHeadlinesNewsResponseModel(
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  @override
  List<Object?> get props => [name];

  @override
  String toString() {
    return 'ItemSourceTopHeadlinesNewsResponseModel{name: $name}';
  }
}
