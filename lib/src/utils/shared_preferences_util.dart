import 'dart:convert';
import 'package:common_utils/common_utils.dart';
import 'package:common_utils/src/mode/user_info_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtil {
  static late SharedPreferences sharedPreferences;

  ///初始化工具
  static Future<bool>  initSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return true;
  }
}


class SharedPreferencesDao {
  static const String _token = "_token";
  static const String _userInfo = "_userInfo";
  static const String _username = "_username";
  static const String _password = "_password";


  ///保存密码
  static void savePassword(String value) {
    SharedPreferencesUtil.sharedPreferences.setString(_password, value);
  }

  /// 获取用户登录密码
  static String getPassWord() {
    String password = "";
    try {
      password = SharedPreferencesUtil.sharedPreferences.getString(_password)!;
    } catch (e) {
      printLog(StackTrace.current,e);
    }
    return password;
  }

  /// 删除用户密码
  static Future<bool> removePassword() async {
    bool isSuccess = true;
    try {
      isSuccess =
      await SharedPreferencesUtil.sharedPreferences.remove(_password);
    } catch (e) {
      printLog(StackTrace.current,e);
    }
    return isSuccess;
  }


  ///保存用户登录token
  static void saveToken(String value) {
    SharedPreferencesUtil.sharedPreferences.setString(_token, value);
  }

  /// 获取用户登录token
  static String getToken() {
    String token = "";
    try {
      token = SharedPreferencesUtil.sharedPreferences.getString(_token)!;
    } catch (e) {
      printLog(StackTrace.current,e);
    }
    return token;
  }

  /// 删除用户登录token
  static Future<bool> removeToken() async {
    bool isSuccess = true;
    try {
      isSuccess = await SharedPreferencesUtil.sharedPreferences.remove(_token);
    } catch (e) {
      isSuccess = false;
      printLog(StackTrace.current,e);
    }
    return isSuccess;
  }


  ///保存用户登录名
  static void saveUsername(String value) {
    SharedPreferencesUtil.sharedPreferences.setString(_username, value);
  }

  /// 获取用户登录名
  static String getUsername() {
    String username = "";
    try {
      username = SharedPreferencesUtil.sharedPreferences.getString(_username)!;
    } catch (e) {
      printLog(StackTrace.current,e);
    }
    return username;
  }


  /// 删除用户登录名
  static Future<bool> removeUsername() async {
    bool isSuccess = true;
    try {
      isSuccess = await SharedPreferencesUtil.sharedPreferences.remove(_username);
    } catch (e) {
      isSuccess = false;
      printLog(StackTrace.current,e);
    }
    return isSuccess;
  }


  ///保存用户信息
  static void saveUserInfo(UserInfoModel value) {
    SharedPreferencesUtil.sharedPreferences.setString(_userInfo, jsonEncode(value).toString());
  }

  /// 获取用户信息
  static UserInfoModel getUserInfo() {
    UserInfoModel userInfoMode = UserInfoModel();
    try {
      String? _userMode = SharedPreferencesUtil.sharedPreferences.getString(_userInfo);
      if (_userMode != null) {
        userInfoMode = UserInfoModel.fromJson(jsonDecode(_userMode));
      }
    } catch (e) {
      printLog(StackTrace.current,e);
    }
    return userInfoMode;
  }

  /// 删除用户信息
  static Future<bool> removeUserInfo() async {
    bool isSuccess = false;
    try {
      isSuccess =
      await SharedPreferencesUtil.sharedPreferences.remove(_userInfo);
    } catch (e) {
      printLog(StackTrace.current,e);
    }
    return isSuccess;
  }
}