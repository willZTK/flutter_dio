import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'net_result_data.dart';

/// 数据初步处理
class NetResponseInterceptor extends InterceptorsWrapper {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    RequestOptions option = response.requestOptions;

    try {
      ///一般只需要处理200的情况，300、400、500保留错误信息，外层为http协议定义的响应码
      if (response.statusCode == 200 || response.statusCode == 201) {
        response.data = NetResultData(response.data, true, 200);
        handler.next(response);
        // var code = response.data["rtnCode"].toString();
        // if (code == "1") {
        //   response.data = ResultData(response.data, true, 200);
        //   handler.next(response);
        // } else {
        //   response.data = ResultData(response.data, false, 200);
        //   handler.next(response);
        // }
      }
    } catch (e) {
      String info = "ResponseError====$e****${option.path}";
      debugPrint(info);
      response.data = NetResultData(response.data, false, response.statusCode!);
      handler.next(response);
    }
  }
}
