import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_news_app/core/error/failure.dart';
import 'package:flutter_news_app/feature/domain/usecase/gettopheadlinesnews/get_top_headlines_news.dart';
import 'package:flutter_news_app/feature/domain/usecase/searchtopheadlinesnews/search_top_headlines_news.dart';

import './bloc.dart';

class TopHeadlinesNewsBloc extends Bloc<TopHeadlinesNewsEvent, TopHeadlinesNewsState> {
  final GetTopHeadlinesNews getTopHeadlinesNews;
  final SearchTopHeadlinesNews searchTopHeadlinesNews;

  TopHeadlinesNewsBloc({
    required this.getTopHeadlinesNews,
    required this.searchTopHeadlinesNews,
  }) : super(InitialTopHeadlinesNewsState()) {
    on<LoadTopHeadlinesNewsEvent>(_onLoadTopHeadlinesNews);
    on<ChangeCategoryTopHeadlinesNewsEvent>(_onChangeCategoryTopHeadlinesNews);
    on<SearchTopHeadlinesNewsEvent>(_onSearchTopHeadlinesNews);
  }

  Future<void> _onLoadTopHeadlinesNews(
    LoadTopHeadlinesNewsEvent event,
    Emitter<TopHeadlinesNewsState> emit,
  ) async {
    emit(LoadingTopHeadlinesNewsState());
    final response = await getTopHeadlinesNews(ParamsGetTopHeadlinesNews(category: event.category));
    response.fold(
      (failure) {
        if (failure is ServerFailure) {
          emit(FailureTopHeadlinesNewsState(errorMessage: failure.errorMessage));
        } else if (failure is ConnectionFailure) {
          emit(FailureTopHeadlinesNewsState(errorMessage: failure.errorMessage));
        }
      },
      (data) => emit(LoadedTopHeadlinesNewsState(listArticles: data.articles)),
    );
  }

  void _onChangeCategoryTopHeadlinesNews(
    ChangeCategoryTopHeadlinesNewsEvent event,
    Emitter<TopHeadlinesNewsState> emit,
  ) {
    emit(ChangedCategoryTopHeadlinesNewsState(indexCategorySelected: event.indexCategorySelected));
  }

  Future<void> _onSearchTopHeadlinesNews(
    SearchTopHeadlinesNewsEvent event,
    Emitter<TopHeadlinesNewsState> emit,
  ) async {
    emit(LoadingTopHeadlinesNewsState());
    final result = await searchTopHeadlinesNews(ParamsSearchTopHeadlinesNews(keyword: event.keyword));
    result.fold(
      (failure) {
        if (failure is ServerFailure) {
          emit(FailureTopHeadlinesNewsState(errorMessage: failure.errorMessage));
        } else if (failure is ConnectionFailure) {
          emit(FailureTopHeadlinesNewsState(errorMessage: failure.errorMessage));
        }
      },
      (response) => emit(SearchSuccessTopHeadlinesNewsState(listArticles: response.articles)),
    );
  }
}
