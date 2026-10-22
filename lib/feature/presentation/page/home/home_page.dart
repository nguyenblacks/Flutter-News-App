import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_news_app/feature/data/model/categorynews/category_news_model.dart';
import 'package:flutter_news_app/feature/data/model/topheadlinesnews/top_headlines_news_response_model.dart';
import 'package:flutter_news_app/feature/presentation/bloc/topheadlinesnews/bloc.dart';
import 'package:flutter_news_app/feature/presentation/page/articleview/articleview.dart';
import 'package:flutter_news_app/feature/presentation/page/search/search_page.dart';
import 'package:flutter_news_app/feature/presentation/page/settings/settings_page.dart';
import 'package:flutter_news_app/feature/presentation/widget/widget_failure_message.dart';
import 'package:flutter_news_app/feature/presentation/widget/widget_item_news.dart';
import 'package:flutter_news_app/injection_container.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final topHeadlinesNewsBloc = sl<TopHeadlinesNewsBloc>();
  final listCategories = const <CategoryNewsModel>[
    CategoryNewsModel(image: '', title: 'All'),
    CategoryNewsModel(image: 'assets/images/img_business.png', title: 'Business'),
    CategoryNewsModel(image: 'assets/images/img_entertainment.png', title: 'Entertainment'),
    CategoryNewsModel(image: 'assets/images/img_health.png', title: 'Health'),
    CategoryNewsModel(image: 'assets/images/img_science.png', title: 'Science'),
    CategoryNewsModel(image: 'assets/images/img_sport.png', title: 'Sports'),
    CategoryNewsModel(image: 'assets/images/img_technology.png', title: 'Technology'),
  ];
  final refreshIndicatorState = GlobalKey<RefreshIndicatorState>();

  bool isLoadingCenterIOS = false;
  Completer<void>? completerRefresh;
  int indexCategorySelected = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Platform.isIOS) {
        isLoadingCenterIOS = true;
        topHeadlinesNewsBloc.add(
          LoadTopHeadlinesNewsEvent(category: listCategories[indexCategorySelected].title.toLowerCase()),
        );
      } else {
        completerRefresh = Completer<void>();
        refreshIndicatorState.currentState?.show();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<TopHeadlinesNewsBloc>(
        create: (context) => topHeadlinesNewsBloc,
        child: BlocListener<TopHeadlinesNewsBloc, TopHeadlinesNewsState>(
          listener: (context, state) {
            if (state is FailureTopHeadlinesNewsState) {
              _resetRefreshIndicator();
            } else if (state is LoadedTopHeadlinesNewsState) {
              _resetRefreshIndicator();
            } else if (state is ChangedCategoryTopHeadlinesNewsState) {
              indexCategorySelected = state.indexCategorySelected;
              if (Platform.isIOS) {
                isLoadingCenterIOS = true;
                var category = listCategories[indexCategorySelected].title.toLowerCase();
                topHeadlinesNewsBloc.add(LoadTopHeadlinesNewsEvent(category: category));
              } else {
                refreshIndicatorState.currentState?.show();
              }
            }
          },
          child: ValueListenableBuilder(
            valueListenable: Hive.box('settings').listenable(),
            builder: (context, box, widget) {
              var isDarkMode = box.get('darkMode') ?? false;
              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: isDarkMode ? null : const Color(0xFFEFF5F5),
                  ),
                  SafeArea(
                    child: Container(
                      width: double.infinity,
                      color: isDarkMode ? null : const Color(0xFFEFF5F5),
                      padding: EdgeInsets.symmetric(
                        vertical: 24.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 48.w),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    'Swavoti News',
                                    style: TextStyle(
                                      fontSize: 48.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const SearchPage()),
                                    );
                                  },
                                  child: Hero(
                                    tag: 'iconSearch',
                                    child: Icon(
                                      Icons.search,
                                      size: 64.w,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 48.w),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SettingsPage(),
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.settings,
                                    size: 64.w,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const WidgetDateToday(),
                          SizedBox(height: 24.h),
                          WidgetCategoryNews(
                              listCategories: listCategories, indexDefaultSelected: indexCategorySelected),
                          SizedBox(height: 24.h),
                          Expanded(
                            child: Platform.isIOS ? _buildWidgetContentNewsIOS() : _buildWidgetContentNewsAndroid(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatPublishedDate(String publishedAt) {
    try {
      final dt = DateTime.parse(publishedAt).toLocal();
      return DateFormat('MMM dd, yyyy HH:mm').format(dt);
    } catch (_) {
      return publishedAt.isNotEmpty ? publishedAt : DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now());
    }
  }

  void _resetRefreshIndicator() {
    if (isLoadingCenterIOS) {
      isLoadingCenterIOS = false;
    }
    if (completerRefresh?.isCompleted == false) {
      completerRefresh?.complete();
    }
    completerRefresh = Completer<void>();
  }

  Widget _buildWidgetContentNewsIOS() {
    return BlocBuilder<TopHeadlinesNewsBloc, TopHeadlinesNewsState>(
      builder: (context, state) {
        var listArticles = <ItemArticleTopHeadlinesNewsResponseModel>[];
        if (state is LoadedTopHeadlinesNewsState) {
          listArticles.addAll(state.listArticles);
        } else if (isLoadingCenterIOS) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }
        return Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.w),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: <Widget>[
                  CupertinoSliverRefreshControl(
                    onRefresh: () {
                      topHeadlinesNewsBloc.add(
                        LoadTopHeadlinesNewsEvent(category: listCategories[indexCategorySelected].title.toLowerCase()),
                      );
                      return completerRefresh?.future ?? Future.value();
                    },
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        var itemArticle = listArticles[index];
                        var strPublishedAt = _formatPublishedDate(itemArticle.publishedAt);
                        if (index == 0) {
                          return _buildWidgetItemLatestNews(itemArticle, strPublishedAt);
                        } else {
                          return _buildWidgetItemNews(index, itemArticle, strPublishedAt);
                        }
                      },
                      childCount: listArticles.length,
                    ),
                  ),
                ],
              ),
            ),
            listArticles.isEmpty && state is! LoadingTopHeadlinesNewsState
                ? _buildWidgetFailureLoadData()
                : Container(),
          ],
        );
      },
    );
  }

  Widget _buildWidgetContentNewsAndroid() {
    return BlocBuilder<TopHeadlinesNewsBloc, TopHeadlinesNewsState>(
      builder: (context, state) {
        var listArticles = <ItemArticleTopHeadlinesNewsResponseModel>[];
        if (state is LoadedTopHeadlinesNewsState) {
          listArticles.addAll(state.listArticles);
        }
        return Stack(
          children: <Widget>[
            RefreshIndicator(
              key: refreshIndicatorState,
              onRefresh: () {
                topHeadlinesNewsBloc.add(
                  LoadTopHeadlinesNewsEvent(category: listCategories[indexCategorySelected].title.toLowerCase()),
                );
                return completerRefresh?.future ?? Future.value();
              },
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 48.w),
                itemBuilder: (context, index) {
                  var itemArticle = listArticles[index];
                  var strPublishedAt = _formatPublishedDate(itemArticle.publishedAt);
                  if (index == 0) {
                    return _buildWidgetItemLatestNews(itemArticle, strPublishedAt);
                  } else {
                    return _buildWidgetItemNews(index, itemArticle, strPublishedAt);
                  }
                },
                itemCount: listArticles.length,
              ),
            ),
            listArticles.isEmpty && state is FailureTopHeadlinesNewsState ? _buildWidgetFailureLoadData() : Container(),
          ],
        );
      },
    );
  }

  Widget _buildWidgetFailureLoadData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const WidgetFailureMessage(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
            ),
            onPressed: () {
              if (Platform.isIOS) {
                isLoadingCenterIOS = true;
                topHeadlinesNewsBloc.add(
                  LoadTopHeadlinesNewsEvent(category: listCategories[indexCategorySelected].title.toLowerCase()),
                );
              } else {
                refreshIndicatorState.currentState?.show();
              }
            },
            child: Text(
              'Try Again'.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 36.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetItemNews(
    int index,
    ItemArticleTopHeadlinesNewsResponseModel itemArticle,
    String strPublishedAt,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: index == 1 ? 32.h : 16.h,
        bottom: 16.h,
      ),
      child: WidgetItemNews(
        itemArticle: itemArticle,
        strPublishedAt: strPublishedAt,
      ),
    );
  }

  Widget _buildWidgetItemLatestNews(
    ItemArticleTopHeadlinesNewsResponseModel itemArticle,
    String strPublishedAt,
  ) {
    return GestureDetector(
      onTap: () {
        if (itemArticle.url.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleView(
                url: itemArticle.url,
                title: itemArticle.title,
              ),
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Couldn\'t open detail news'),
          ));
        }
      },
      child: Container(
        width: double.infinity,
        height: 1.sw / 1.7,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          image: DecorationImage(
            image: NetworkImage(
              itemArticle.urlToImage,
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 1.sw / 1.7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black,
                    Colors.black.withValues(alpha: 0.0),
                  ],
                  stops: const [
                    0.0,
                    1.0,
                  ],
                ),
              ),
              padding: EdgeInsets.all(48.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    itemArticle.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 48.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        strPublishedAt,
                        style: TextStyle(
                          fontSize: 28.sp,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        ' | ',
                        style: TextStyle(
                          fontSize: 28.sp,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        itemArticle.source.name,
                        style: TextStyle(
                          fontSize: 28.sp,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WidgetCategoryNews extends StatefulWidget {
  final List<CategoryNewsModel> listCategories;
  final int indexDefaultSelected;

  const WidgetCategoryNews({
    super.key,
    required this.listCategories,
    required this.indexDefaultSelected,
  });

  @override
  State<WidgetCategoryNews> createState() => _WidgetCategoryNewsState();
}

class _WidgetCategoryNewsState extends State<WidgetCategoryNews> {
  int indexCategorySelected = 0;

  @override
  void initState() {
    indexCategorySelected = widget.indexDefaultSelected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 48.w),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          var itemCategory = widget.listCategories[index];
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 12.w,
              right: index == widget.listCategories.length - 1 ? 0 : 12.w,
            ),
            child: GestureDetector(
              onTap: () {
                if (indexCategorySelected == index) {
                  return;
                }
                setState(() => indexCategorySelected = index);
                var topHeadlinesNewsBloc = BlocProvider.of<TopHeadlinesNewsBloc>(context);
                topHeadlinesNewsBloc.add(
                  ChangeCategoryTopHeadlinesNewsEvent(indexCategorySelected: index),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: itemCategory.title.toLowerCase() == 'all' ? const Color(0xFFBBCDDC) : null,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(4),
                  ),
                  image: itemCategory.title.toLowerCase() == 'all'
                      ? null
                      : DecorationImage(
                          image: AssetImage(
                            itemCategory.image,
                          ),
                          fit: BoxFit.cover,
                        ),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: itemCategory.title.toLowerCase() == 'all' ? 48.w : 32.w,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: indexCategorySelected == index ? 0.2 : 0.6),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(4),
                    ),
                    border: indexCategorySelected == index
                        ? Border.all(
                            color: Colors.white,
                            width: 2.0,
                          )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      itemCategory.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        itemCount: widget.listCategories.length,
      ),
    );
  }
}

class WidgetDateToday extends StatefulWidget {
  const WidgetDateToday({super.key});

  @override
  State<WidgetDateToday> createState() => _WidgetDateTodayState();
}

class _WidgetDateTodayState extends State<WidgetDateToday> {
  String strToday = '';

  @override
  void initState() {
    strToday = DateFormat('EEEE, MMM dd, yyyy').format(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 48.w),
      child: Text(
        strToday,
        style: TextStyle(
          fontSize: 28.sp,
          color: Colors.grey,
        ),
      ),
    );
  }
}
