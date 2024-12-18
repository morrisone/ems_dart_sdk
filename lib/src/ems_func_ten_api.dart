import 'package:dart_ems_sdk/entity/ten_device_entity.dart';
import 'package:flutter/foundation.dart';

import 'ems_connect_manager.dart';

enum TenControlDeviceType { start, end, pause, continues }

typedef CallBackWriteStatus = void Function(bool isSuccess);
typedef CallBackVersion = void Function(bool isSuccess, String version);
typedef CallBackPower = void Function(
    bool isSuccess, TenDevicePower tenDevicePower);
typedef CallBackReportModel = void Function(
    bool isSuccess, EMSReportModel tenDevicePower);

class EmsTenFuncManager {
  /// 十路查询版本
  static Future<void> getVersion(CallBackVersion callBackVersion) async {
    ConnectManager
        .getInstance()
        .versionTenEventBus
        .on<String>()
        .listen((event) {
      if (event.isEmpty) {
        callBackVersion(false, event);
      } else {
        callBackVersion(true, event);
      }
    });

    List<int> getVersion = [0x3B, 0x00, 0x07, 0x00, 0x2f, 0x71, 0x0A];
    try {
      await ConnectManager
          .getInstance()
          .characteristic
          ?.write(getVersion,
          withoutResponse: ConnectManager
              .getInstance()
              .characteristic!
              .properties
              .writeWithoutResponse);
    } catch (e) {
      if (kDebugMode) {
        print("Write Error:");
      }
    }
  }

  /* 十路 发送参数
    * @param frequency 频率
    * @param pulseWidth 脉宽
    * @param fundamentalWave 基波
    * @param carrierWave 载波
    * @param duration 保持时间
    * @param interval 休息时间
    * @param upTime 上升时间间隔
    * @param downTime 下降时间间隔
   */
  static Future<void> sendParam(int frequency,
      int pulseWidth,
      int fundamentalWave,
      int carrierWave,
      int duration,
      int interval,
      int upTime,
      int downTime,
      CallBackWriteStatus callBackWriteStatus) async {
    //保持时间就是放电时间 休息时间就是间隔时间,上升时间和下降时间是固定的15
    if (frequency * pulseWidth >= 100000) {
      callBackWriteStatus(false);
      return;
    }
    if (frequency < 1 || frequency > 200) {
      callBackWriteStatus(false);
      return;
    }
    if (pulseWidth < 10 || pulseWidth > 100) {
      callBackWriteStatus(false);
      return;
    }
    int valid = (0x3B +
        0x00 +
        0x14 +
        0x00 +
        0x01 +
        frequency +
        pulseWidth +
        fundamentalWave +
        carrierWave +
        0x00 +
        upTime +
        0x00 +
        duration +
        0x00 +
        downTime +
        0x00 +
        interval) &
    0xff;
    List<int> param = [
      0x3B,
      0x00,
      0x14,
      0x00,
      0x01,
      0x00,
      frequency,
      pulseWidth,
      fundamentalWave,
      carrierWave,
      0x00,
      upTime,
      0x00,
      duration,
      0x00,
      downTime,
      0x00,
      interval,
      valid,
      0x0A
    ];
    try {
      await ConnectManager
          .getInstance()
          .characteristic
          ?.write(param,
          withoutResponse: ConnectManager
              .getInstance()
              .characteristic!
              .properties
              .writeWithoutResponse);
      callBackWriteStatus(true);
    } catch (e) {
      if (kDebugMode) {
        print("Write Error:");
      }
      callBackWriteStatus(false);
    }
  }

  /// 操作设备
  Future<void> controlDevice(TenControlDeviceType type,
      CallBackWriteStatus callBackWriteStatus) async {
    int byte = 0;
    switch (type) {
      case TenControlDeviceType.start:
        byte = 0x02;
        break;
      case TenControlDeviceType.end:
        byte = 0x03;
        break;
      case TenControlDeviceType.pause:
        byte = 0x04;
        break;
      case TenControlDeviceType.continues:
        byte = 0x05;
        break;
    }
    int valid = (0x3B + 0x00 + 0x07 + 0x00 + byte) & 0xff;
    List<int> bytes = [0x3B, 0x00, 0x07, 0x00, byte, valid, 0x0A];
    try {
      await ConnectManager
          .getInstance()
          .characteristic
          ?.write(bytes,
          withoutResponse: ConnectManager
              .getInstance()
              .characteristic!
              .properties
              .writeWithoutResponse);
      callBackWriteStatus(true);
    } catch (e) {
      if (kDebugMode) {
        print("Write Error:");
      }
      callBackWriteStatus(false);
    }
  }

  /* 十路 发送时间
    * @param bufferTime 上升下降时间/10
    * @param durationTime 保持时间
    * @param intervalTime 休息时间
   */
  static Future<void> sendTime(int bufferTime, int durationTime,
      int intervalTime, CallBackWriteStatus callBackWriteStatus) async {
    int bufferIntTime = bufferTime * 10;
    int valid = (0x3B +
        0x00 +
        0x0f +
        0x00 +
        0x06 +
        0x00 +
        bufferIntTime +
        0x00 +
        durationTime +
        0x00 +
        bufferIntTime +
        0x00 +
        intervalTime) &
    0xff;
    List<int> bytes = [
      0x3B,
      0x00,
      0x0f,
      0x00,
      0x06,
      0x00,
      bufferIntTime,
      0x00,
      durationTime,
      0x00,
      bufferIntTime,
      0x00,
      intervalTime,
      valid,
      0x0A
    ];
    try {
      await ConnectManager
          .getInstance()
          .characteristic
          ?.write(bytes,
          withoutResponse: ConnectManager
              .getInstance()
              .characteristic!
              .properties
              .writeWithoutResponse);
      callBackWriteStatus(true);
    } catch (e) {
      if (kDebugMode) {
        print("Write Error:");
      }
      callBackWriteStatus(false);
    }
  }

  /* 十路 发送强度
    * @param strength 十路 每路强度
   */
  static Future<void> sendStrength(List<int> strength,
      CallBackWriteStatus callBackWriteStatus) async {
    List<int> bytes = [0x3B, 0x00, 0x11, 0x00, 0x07];
    int num = bytes.reduce((value, element) => value + element);
    for (var element in strength) {
      num = num + element;
      bytes.add(element);
    }
    int valid = num & 0xff;
    bytes.add(valid);
    bytes.add(0x0A);

    try {
      await ConnectManager
          .getInstance()
          .characteristic
          ?.write(bytes,
          withoutResponse: ConnectManager
              .getInstance()
              .characteristic!
              .properties
              .writeWithoutResponse);
      callBackWriteStatus(true);
    } catch (e) {
      if (kDebugMode) {
        print("Write Error:");
      }
      callBackWriteStatus(false);
    }
  }

  /* 十路 电极平衡
    * @param
   */
  static Future<void> sendBalance(int left, int right,
      CallBackWriteStatus callBackWriteStatus) async {
    int valid = (0x3B + 0x00 + 0x09 + 0x00 + 0x09 + left + right) & 0xff;
    List<int> bytes = [0x3B, 0x00, 0x09, 0x00, 0x09, left, right, valid, 0x0A];
    try {
      await ConnectManager
          .getInstance()
          .characteristic
          ?.write(bytes,
          withoutResponse: ConnectManager
              .getInstance()
              .characteristic!
              .properties
              .writeWithoutResponse);
      callBackWriteStatus(true);
    } catch (e) {
      if (kDebugMode) {
        print("Write Error:");
      }
      callBackWriteStatus(false);
    }
  }

  /* 十路 获取电量
    * @param
   */
  static Future<void> getPower(CallBackPower callBackPower) async {
    ConnectManager
        .getInstance()
        .powerTenEventBus
        .on<TenDevicePower>()
        .listen((event) {
      if (event.percent > 0) {
        callBackPower(true, event);
      } else {
        callBackPower(false, event);
      }
    });
    int valid = (0x3B + 0x00 + 0x07 + 0x00 + 0x0a) & 0xff;
    List<int> bytes = [0x3B, 0x00, 0x07, 0x00, 0x0a, valid, 0x0A];
    try {
      await ConnectManager
          .getInstance()
          .characteristic
          ?.write(bytes,
          withoutResponse: ConnectManager
              .getInstance()
              .characteristic!
              .properties
              .writeWithoutResponse);
    } catch (e) {
      if (kDebugMode) {
        print("Write Error:");
      }
      callBackPower(false, TenDevicePower());
    }
  }

  /* 十路 关机
    * @param
   */
  static Future<void> closeDevice(
      CallBackWriteStatus callBackWriteStatus) async {
    int valid = (0x3B + 0x00 + 0x07 + 0x00 + 0x0e) & 0xff;
    List<int> bytes = [0x3B, 0x00, 0x07, 0x00, 0x0e, valid, 0x0A];
    try {
      await ConnectManager
          .getInstance()
          .characteristic
          ?.write(bytes,
          withoutResponse: ConnectManager
              .getInstance()
              .characteristic!
              .properties
              .writeWithoutResponse);
      callBackWriteStatus(true);
    } catch (e) {
      if (kDebugMode) {
        print("Write Error:");
      }
      callBackWriteStatus(false);
    }
  }

  /* 十路 老化设备
    * @param
   */
  static Future<void> maturingDevice(
      CallBackWriteStatus callBackWriteStatus) async {
    int valid = (0x3B + 0x00 + 0x07 + 0x00 + 0x1d) & 0xff;
    List<int> bytes = [0x3B, 0x00, 0x07, 0x00, 0x1d, valid, 0x0A];
    try {
      await ConnectManager
          .getInstance()
          .characteristic
          ?.write(bytes,
          withoutResponse: ConnectManager
              .getInstance()
              .characteristic!
              .properties
              .writeWithoutResponse);
      callBackWriteStatus(true);
    } catch (e) {
      if (kDebugMode) {
        print("Write Error:");
      }
      callBackWriteStatus(false);
    }
  }

/* 十路 查看体脂数据
    * @param height 身高 cm
    * @param gender 性别 1 男 0 女
    * @param age 年龄
    * @param weight 体重
   */
  static Future<void> checkBodyFat(int height, int gender, int age,
      double weight, CallBackReportModel callBackReportModel) async {
    int heightWeight = weight.truncate();
    int lowWeight = ((weight * 10).truncate() % 10) * 10;
    int valid = (0x3B +
        0x00 +
        0x0c +
        0x00 +
        0x0c +
        heightWeight +
        lowWeight +
        height +
        age +
        gender) &
    0xff;
    List<int> bytes = [
      0x3B,
      0x00,
      0x0c,
      0x00,
      0x0c,
      heightWeight,
      lowWeight,
      height,
      age,
      gender,
      valid,
      0x0A
    ];

    ConnectManager
        .getInstance()
        .fatDataTenEventBus
        .on<TenFatStatus>()
        .listen((event) {
      if (event.isSuccess == false) {
        callBackReportModel(false, EMSReportModel());
      } else {
        callBackReportModel(true,EMSReportModel.getFrom(event.data, weight));
      }
    });
    EmsTenFuncManager.checkFat(bytes);
  }

  static Future<void> checkFat(List<int> bytes) async {
    try {
      await ConnectManager
          .getInstance()
          .characteristic
          ?.write(bytes,
          withoutResponse: ConnectManager
              .getInstance()
              .characteristic!
              .properties
              .writeWithoutResponse);
    } catch (e) {
      if (kDebugMode) {
        print("Write Error:");
      }
    }
  }
}
