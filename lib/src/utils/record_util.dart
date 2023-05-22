import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:flutter_sound_lite/public/flutter_sound_recorder.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

typedef OnResultCallBack = Function();

class RecordUtil {
  static Codec _codec = Codec.aacMP4;
  static late String _tempRecordPath = "";

  static final FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  static final FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();


  /// 打开麦克风的初始化工作
  static Future<void> openRecorderBeforeInit({String? tempRecordPath}) async {
    if(tempRecordPath != null && tempRecordPath != ""){
      _tempRecordPath = tempRecordPath;
    }else{
      Directory tempDir = await getTemporaryDirectory();
      var time = DateTime.now().millisecondsSinceEpoch;
      _tempRecordPath = '${tempDir.path}/message-$time-${ext[Codec.aacADTS.index]}';
      /// 申请麦克风权限
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }

      await _mRecorder!.openAudioSession();
      /// 判断是否是WEB环境
      if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
        _codec = Codec.opusWebM;
        _tempRecordPath = '${tempDir.path}/$time/message.webm';
        if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
          return;
        }
      }
    }
  }

  /// 打开音频会话
  static Future<void> openAudioSession() async {
    await _mPlayer!.openAudioSession();
  }

  /// 关闭音频会话
  static Future<void> closeAudioSession() async {
    await  _mPlayer!.closeAudioSession();
  }

  /// 播放音频
  static void playRecorder({required OnResultCallBack onResultCallBack, String? recordSourcesPath}) async {
    if (!_mPlayer!.isOpen()) {
      await openAudioSession();
    }
    _mPlayer!.startPlayer(
        fromURI: recordSourcesPath??_tempRecordPath,
        whenFinished: () => onResultCallBack()
    ).then((value) {});
  }

  /// 开始录音
  static void startRecorder({required OnResultCallBack onResultCallBack, String? recordSourcesPath}) async {
    if (!_mPlayer!.isOpen()) {
      await openAudioSession();
    }
    _mRecorder!.startRecorder(toFile: recordSourcesPath??_tempRecordPath, codec: _codec, audioSource: AudioSource.microphone).then((value)=> onResultCallBack());
  }

  /// 结束录音
  static void stopRecorder(OnResultCallBack onResultCallBack) async {
    await _mRecorder!.stopRecorder().then((value) => onResultCallBack());
  }
}