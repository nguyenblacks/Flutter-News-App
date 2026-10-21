import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_news_app/feature/presentation/bloc/topheadlinesnews/bloc.dart';
import 'package:flutter_news_app/feature/presentation/widget/widget_failure_message.dart';
import 'package:flutter_news_app/feature/presentation/widget/widget_item_news.dart';
import 'package:flutter_news_app/injection_container.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final topHeadlinesNewsBloc = sl<TopHeadlinesNewsBloc>();
  final controllerKeyword = TextEditingController();
  final focusNodeIconSearch = FocusNode();
  String keyword = '';
  Timer? debounce;

  @override
  void initState() {
    controllerKeyword.addListener(_onSearching);
    super.initState();
  }

  @override
  void dispose() {
    focusNodeIconSearch.dispose();
    controllerKeyword.removeListener(_onSearching);
    controllerKeyword.dispose();
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var isDarkTheme = theme.brightness == Brightness.dark;
    return Scaffold(
      body: BlocProvider<TopHeadlinesNewsBloc>(
        create: (context) => topHeadlinesNewsBloc,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: isDarkTheme ? null : const Color(0xFFEFF5F5),
            ),
            SafeArea(
              child: Container(
                color: isDarkTheme ? null : const Color(0xFFEFF5F5),
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: 24.h,
                  horizontal: 48.w,
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                          ),
                        ),
                        SizedBox(width: 24.w),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(99.0),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 36.w),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextField(
                                    controller: controllerKeyword,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'Searching something?',
                                      hintStyle: TextStyle(
                                        fontSize: 36.sp,
                                        color: Colors.grey,
                                      ),
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                    style: TextStyle(
                                      fontSize: 36.sp,
                                    ),
                                  ),
                                ),
                                Hero(
                                  tag: 'iconSearch',
                                  child: Focus(
                                    focusNode: focusNodeIconSearch,
                                    child: Icon(
                                      Icons.search,
                                      size: 48.w,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: BlocBuilder<TopHeadlinesNewsBloc, TopHeadlinesNewsState>(
                        builder: (context, state) {
                          if (state is LoadingTopHeadlinesNewsState) {
                            return Center(
                              child: Platform.isIOS ? const CupertinoActivityIndicator() : const CircularProgressIndicator(),
                            );
                          } else if (state is FailureTopHeadlinesNewsState) {
                            return const WidgetFailureMessage();
                          } else if (state is SearchSuccessTopHeadlinesNewsState) {
                            var listArticles = state.listArticles;
                            if (listArticles.isEmpty) {
                              return const WidgetFailureMessage(
                                errorTitle: 'Data not found',
                                errorSubtitle: 'Hm, we couldn\'t find what you were looking for.',
                              );
                            } else {
                              return ListView.builder(
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) {
                                  var itemArticle = listArticles[index];
                                  String strPublishedAt;
                                  try {
                                    final dt = DateTime.parse(itemArticle.publishedAt).toLocal();
                                    strPublishedAt = DateFormat('MMM dd, yyyy HH:mm').format(dt);
                                  } catch (_) {
                                    strPublishedAt = itemArticle.publishedAt.isNotEmpty
                                        ? itemArticle.publishedAt
                                        : DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now());
                                  }
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.h),
                                    child: WidgetItemNews(
                                      itemArticle: itemArticle,
                                      strPublishedAt: strPublishedAt,
                                    ),
                                  );
                                },
                                itemCount: listArticles.length,
                              );
                            }
                          }
                          return Container();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearching() {
    if (debounce?.isActive ?? false) {
      debounce?.cancel();
    }
    debounce = Timer(const Duration(milliseconds: 800), () {
      var currentKeyword = controllerKeyword.text.trim();
      if (currentKeyword.isEmpty || keyword == currentKeyword) {
        return;
      }
      keyword = currentKeyword;
      focusNodeIconSearch.requestFocus();
      topHeadlinesNewsBloc.add(SearchTopHeadlinesNewsEvent(keyword: currentKeyword));
    });
  }
}
