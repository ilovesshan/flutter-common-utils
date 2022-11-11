import 'dart:async';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';

class HttpHelper {
  static HttpHelper? _httpHelper;
  static late Dio _dio;

  HttpHelper._internal();

  factory HttpHelper.getInstance() => _getInstance();

  static _getInstance() {
    if (_httpHelper == null) {
      _httpHelper = HttpHelper._internal();
      _createDio();
    }
    return _httpHelper;
  }

  /// 创建Dio 实例
  static void _createDio() {
    _dio = Dio(BaseOptions(
      // baseUrl: HttpHelperConfig.baseurl,
      method: HttpHelperConfig.defaultMethod,
      headers: {},
      queryParameters: {},
      connectTimeout: HttpHelperConfig.connectTimeout,
      receiveTimeout: HttpHelperConfig.receiveTimeout,
    ));

    // 添加拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {

        /// 由于HttpHelper是单例模式   baseUrl会被切换 每次请求时更新一下
        // options.baseUrl = HttpHelperConfig.baseurl;

        /// 当前接口是需要 application/x-www-form-urlencoded 格式的  (dio默认是 application/json; charset=utf-8 格式)
        if (HttpHelperConfig.needXWwwFormUrlencodedTypeList.contains(options.path)) {
          options.contentType = "application/x-www-form-urlencoded";
        }

        /// 统一处理：请求时需要携带Token
        Map<String, String> tokenMap = {
          /// 格式需要和后端配合
          "Authorization": "Bearer " + TextUtils.isValidWith(SharedPreferencesDao.getToken().toString(), ""),
        };

        /// 公共请求头
        Map<String, String> publicHeaderMap = {
          "X-Requested-With": "XMLHttpRequest"
        };


        options.headers.addAll(publicHeaderMap);
        options.headers.addAll(tokenMap);

        debugPrint("***************************请求拦截***************************");
        // debugPrint('请求地址: ${HttpHelperConfig.baseurl + options.path}');
        debugPrint('请求地址: ${options.path}');
        debugPrint('请求方式: ${options.method}');
        debugPrint('请求参数(Parameters): ${options.queryParameters.toString()}');
        debugPrint('请求参数(data): ${options.data.toString()}');
        debugPrint('请求头(headers): ${options.headers.toString()}');
        debugPrint("***************************请求拦截***************************");
        handler.next(options);
      },
      onResponse: (Response e, ResponseInterceptorHandler handler) {
        EasyLoading.dismiss();
        debugPrint("***************************请求响应拦截*************************");
        debugPrint(e.toString());
        debugPrint("***************************请求响应拦截*************************");
        handler.next(e);
      },
      onError: (DioError e, ErrorInterceptorHandler handler) {
        handler.next(e);
        debugPrint("***************************请求错误拦截*************************");
        if (e is DioError) {
          if (e.response != null && e.response!.data != null) {
            debugPrint(e.response!.data.toString());
          } else {
            debugPrint(e.error.toString());
          }
        } else {
          debugPrint(e.message);
        }
        debugPrint("***************************请求错误拦截*************************");
        switch (e.type) {
          case DioErrorType.cancel:
            EasyLoading.showToast("请求取消");
            break;
          case DioErrorType.connectTimeout:
            EasyLoading.showToast("连接超时");
            break;
          case DioErrorType.receiveTimeout:
            EasyLoading.showToast("响应超时");
            break;
          case DioErrorType.sendTimeout:
            EasyLoading.showToast("请求超时");
            break;
          case DioErrorType.other:
            EasyLoading.showToast("请求失败: ${e.error.toString()}");
            break;
          case DioErrorType.response:
            switch (e.response?.statusCode) {
              case 400:
                EasyLoading.showToast("请求失败：${e.response!.data.toString()}");
               break;
              case 401:
                EasyLoading.showToast("请求失败：没有权限");
                break;
              case 403:
                EasyLoading.showToast("请求失败：服务器拒绝执行");
                break;
              case 404:
                EasyLoading.showToast("请求失败：无法连接服务器 404");
                break;
              case 405:
                EasyLoading.showToast("请求失败：请求方法被禁止");
                break;
              case 500:
                EasyLoading.showToast(e.response!.data.toString());
                break;
              case 502:
                EasyLoading.showToast("请求失败：无效的请求");
                break;
              case 503:
                EasyLoading.showToast("请求失败：服务器繁忙");
                break;
              case 505:
                EasyLoading.showToast("请求失败：不支持HTTP协议请求");
                break;
              default:
                EasyLoading.showToast("请求失败：请稍后再试 ${e.response!.data.toString()}");
            }
            break;
          default:
            EasyLoading.showToast("请求失败：请稍后再试");
        }
      },
    ));
  }

  /// GET 请求
  Future<Response> get(String url, {Map<String, dynamic>? params, data, OnSuccess? onSuccess, OnError? onError, OnCompleted? onCompleted}) async {Options options = Options(method: "GET");
    return _baseRequest(url, params ?? {}, data, options, onSuccess, onError, onCompleted);
  }


  /// POST 请求
  Future<Response> post(String url, {Map<String, dynamic>? params, data, OnSuccess? onSuccess, OnError? onError, OnCompleted? onCompleted}) async {
    Options options = Options(method: "POST");
    return _baseRequest(url, params ?? {}, data, options, onSuccess, onError, onCompleted);
  }


  /// PUT 请求
  Future<Response> put(String url, {Map<String, dynamic>? params, data, OnSuccess? onSuccess, OnError? onError, OnCompleted? onCompleted}) async {
    Options options = Options(method: "PUT");
    return _baseRequest(url, params ?? {}, data, options, onSuccess, onError, onCompleted);
  }


  /// DELETE 请求
  Future<Response> delete(String url, {Map<String, dynamic>? params, data, OnSuccess? onSuccess, OnError? onError, OnCompleted? onCompleted}) async {
    Options options = Options(method: "DELETE");
    return _baseRequest(url, params ?? {}, data, options, onSuccess, onError, onCompleted);
  }


  /// 通用请求方法
  static Future<Response> _baseRequest(String url, Map<String, dynamic> params, data, Options options, OnSuccess? onSuccess, OnError? onError, OnCompleted? onCompleted) async {
    late Response result;
    try {
      result = await _dio.request<dynamic>(url, queryParameters: params, data: data, options: options);

      /// 通过回调函数的方式 处理请求结果
      if (result.statusCode == 200) {
        // 成功
        if (onSuccess != null) {
          onSuccess(result.data);
        }
      } else {
        // /失败
        if (onError != null) {
          int errorCode = int.parse(result.statusCode.toString());
          String errorMessage = result.statusMessage.toString();
          onError(errorCode, errorMessage);
        }
      }
      /// 请求结束之后,做一些其他操作
      if (onCompleted != null) {
        onCompleted();
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
