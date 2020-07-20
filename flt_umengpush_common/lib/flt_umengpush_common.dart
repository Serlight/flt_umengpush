import 'dart:async';
import 'dart:ffi';

import 'package:flutter/services.dart';

class FltUmengpushCommon {
  /*设备类型：手机 */
  static const int DEVICE_TYPE_PHONE = 1;
  /*设备类型：盒子 */
  static const int DEVICE_TYPE_BOX = 2;

  static const MethodChannel _channel =
      const MethodChannel('plugin.bughub.dev/flt_umengpush_common');

  /*
   * 初始化方法
   */
  static Future<Void> init(String appKey, String secret,
      [String channel, int deviceType]) async {
    return await _channel.invokeMethod('init', {
      "appKey": appKey,
      "secret": secret,
      "channel": channel,
      "deviceType": deviceType
    });
  }

  /*
  * 是否开启日志
  */
  static Future<Void> setLogEnabled(bool enabled) async {
    return await _channel.invokeMethod('setLogEnabled', {"enabled": enabled});
  }

  static Future<bool> pageStart(String viewName) async {
    Map<String, dynamic> map = {
      'viewName': viewName,
    };

    return _channel.invokeMethod<bool>('pageStart', map);
  }

  /// Send a page end event for [viewName]
  static Future<bool> pageEnd(String viewName) async {
    Map<String, dynamic> map = {
      'viewName': viewName,
    };

    return _channel.invokeMethod<bool>('pageEnd', map);
  }

  /// Send a general event for [eventId] with a [label]
  static Future<bool> event(String eventId, {String label}) async {
    Map<String, dynamic> map = {
      'eventId': eventId,
    };

    if (label != null) {
      map['label'] = label;
    }

    return _channel.invokeMethod<bool>('event', map);
  }
}
