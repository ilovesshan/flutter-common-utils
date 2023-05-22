import 'dart:io';
import 'dart:typed_data';

import 'package:common_utils/common_utils.dart';
import 'package:common_utils/src/utils/time_util.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FileSaverUtil {

  /// 下载图片
  static Future<void> downloadImage(String imageUrl, {bool isAsset = false, String fileName = ""}) async {
    EasyLoading.show(status: "下载中....");
    try {
      var response = await Dio().get(imageUrl, options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaver.saveImage(Uint8List.fromList(response.data), quality: 60, name: TextUtils.isValidWith(fileName, TimeUtil.currentTimeMillis().toString()));
      printLog(StackTrace.current, result);
      EasyLoading.showToast("下载成功");
    } catch (e) {
      EasyLoading.showToast("下载失败");
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// 通用的文件下载
  static Future<String> downLoadFile(String remoteResourceUri) async {
    String extName = remoteResourceUri.substring(remoteResourceUri.lastIndexOf("/") + 1);
    Directory tempDir = await getTemporaryDirectory();
    String fileName = "${tempDir.path}/$extName";
    File file = File(fileName);
    final exists = await file.exists();
    if (exists) {
      return fileName;
    } else {
      try {
        Fluttertoast.showToast(msg: "缓冲中请稍后...");
        var response = await Dio().get(remoteResourceUri, options: Options(responseType: ResponseType.bytes));
        await file.create(recursive: true);
        await file.writeAsBytes(response.data);
        return fileName;
      } catch (e) {
        Fluttertoast.showToast(msg: "缓冲失败");
      }
    }
    return "";
  }
}
