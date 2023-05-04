// ignore_for_file: constant_identifier_names

import 'package:dio/dio.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';

import 'net_config.dart';
import 'net_loading.dart';
import 'net_log_interceptor.dart';
import 'net_response_interceptor.dart';
import 'net_result_data.dart';
import 'net_url_path.dart';

enum DioMethod {
  get,
  post,
  put,
  delete,
  patch,
  head,
}

enum DioContentType {
  json,
  x_www_form_urlencoded,
  text_plain,
}

class NetManager {
  Dio _dio = Dio();
  static final NetManager _instance = NetManager._internal();

  factory NetManager() => _instance;

  int connectTimeout = 15000;

  ///通用全局单例，第一次使用时初始化
  NetManager._internal() {
    _dio = Dio(BaseOptions(
        baseUrl: NetUrlPath.produceUrl, connectTimeout: connectTimeout));
    _dio.interceptors.add(NetLogInterceptor());
    _dio.interceptors.add(NetResponseInterceptor());
  }

  static NetManager getInstance() {
    CompilationMode mode = NetConfig.compilationMode();
    if (mode == CompilationMode.isDebug) {
      return _instance._test();
    } else {
      return _instance._normal();
    }
  }

  //一般请求，默认域名
  NetManager _normal() {
    _dio.options.baseUrl = NetUrlPath.produceUrl;
    return this;
  }

  //测试请求，
  NetManager _test() {
    _dio.options.baseUrl = NetUrlPath.testUrl;
    return this;
  }

  request(
    String path, {
    withLoading = true,
    DioMethod method = DioMethod.post,
    DioContentType contentType = DioContentType.json,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
    data,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (withLoading) {
      Loading.show();
    }

    const methodValues = {
      DioMethod.get: 'get',
      DioMethod.post: 'post',
      DioMethod.put: 'put',
      DioMethod.delete: 'delete',
      DioMethod.patch: 'patch',
      DioMethod.head: 'head'
    };

    const contentTypeValues = {
      DioContentType.json: 'application/json',
      DioContentType.x_www_form_urlencoded: 'application/x-www-form-urlencoded',
      DioContentType.text_plain: 'text/plain'
    };

    options ??= Options();
    options = options.copyWith(method: methodValues[method], headers: headers);
    options.contentType = contentTypeValues[contentType];
    options.responseType = ResponseType.json;
    Response response;
    try {
      response = await _dio.request(path,
          data: data,
          queryParameters: params,
          cancelToken: cancelToken,
          options: options,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress);
    } on DioError catch (e) {
      if (withLoading) {
        Loading.dismiss();
      }
      onErrorInterceptor(e);
      return NetResultData("", false, -1);
    }
    if (withLoading) {
      Loading.dismiss();
    }

    return response.data;
  }

  upload(
    String path, {
    withLoading = true,
    DioMethod method = DioMethod.post,
    DioContentType contentType = DioContentType.json,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
    data,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (withLoading) {
      Loading.show();
    }

    options ??= Options();
    options = options.copyWith(method: 'post', headers: headers);
    options.contentType = "multipart/form-data";
    Response response;
    try {
      response = await _dio.request(path,
          data: data,
          queryParameters: params,
          cancelToken: cancelToken,
          options: options,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress);
    } on DioError catch (e) {
      if (withLoading) {
        Loading.dismiss();
      }
      onErrorInterceptor(e);
      return NetResultData("", false, -1);
    }
    if (withLoading) {
      Loading.dismiss();
    }

    return response.data;
  }
}

onErrorInterceptor(DioError err) async {
  int? statusCode = err.response?.statusCode;

  bool isConnected = await SimpleConnectionChecker.isConnectedToInternet();
  if (!isConnected) {
    Loading.showInfo('网络未连接');
    return;
  }
  if (statusCode == 403) {
    // Loading.dismiss();
    // Loading.showInfo('登录过期，请重新登录');
    // BuildContext? context = Global.navigatorKey.currentState?.context;
    // if (context != null) {
    //   Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    // }
    return;
  }
  // 异常分类
  switch (err.type) {
    case DioErrorType.response:
      err.requestOptions.extra["errorMsg"] = err.response?.data ?? "连接异常";
      break;
    case DioErrorType.connectTimeout:
      err.requestOptions.extra["errorMsg"] = "连接超时";
      break;
    case DioErrorType.sendTimeout:
      err.requestOptions.extra["errorMsg"] = "发送超时";
      break;
    case DioErrorType.receiveTimeout:
      err.requestOptions.extra["errorMsg"] = "接收超时";
      break;
    case DioErrorType.cancel:
      err.requestOptions.extra["errorMsg"] =
          err.message.isNotEmpty ? err.message : "取消连接";
      break;
    case DioErrorType.other:
      break;
    default:
      break;
  }

  dynamic a = err.requestOptions.extra["errorMsg"];
  String msg = '';

  if (a is String) {
    msg = a;
  } else if (a is Map) {
    var list = a['detail'];
    if (list is List) {
      msg = list[0]['msg'];
    } else if (list is String) {
      msg = list;
    } else {
      msg = '网络连接异常,请检查您的网络是否可用';
    }
  } else {
    msg = '网络连接异常,请检查您的网络是否可用';
  }
  Loading.showInfo(msg);
}
