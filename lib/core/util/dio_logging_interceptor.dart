// ignore_for_file: avoid_print
import 'package:dio/dio.dart';
import 'package:flutter_news_app/config/flavor_config.dart';

class DioLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (FlavorConfig.instance.flavor == Flavor.development) {
      print("--> ${options.method.toUpperCase()} ${options.baseUrl}${options.path}");
      print('Headers:');
      options.headers.forEach((k, v) => print('$k: $v'));
      print('queryParameters:');
      options.queryParameters.forEach((k, v) => print('$k: $v'));
      if (options.data != null) {
        print('Body: ${options.data}');
      }
      print("--> END ${options.method.toUpperCase()}");
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (FlavorConfig.instance.flavor == Flavor.development) {
      print("<-- ${response.statusCode} ${response.requestOptions.baseUrl + response.requestOptions.path}");
      print('Headers:');
      response.headers.forEach((k, v) => print('$k: $v'));
      print('Response: ${response.data}');
      print('<-- END HTTP');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (FlavorConfig.instance.flavor == Flavor.development) {
      print("<-- ${err.message} ${err.requestOptions.baseUrl + err.requestOptions.path}");
      print("${err.response != null ? err.response?.data : 'Unknown Error'}");
      print('<-- End error');
    }
    super.onError(err, handler);
  }
}
