import 'package:dart_ems_sdk/ems_connect_manager.dart';
import 'package:dart_ems_sdk/entity/three_device_entity.dart';
import 'package:flutter/foundation.dart';

typedef CallBackThree = void Function(bool isSuccess, ThreeDeviceStatus three);
typedef CallBackWriteStatus = void Function(bool isSuccess);
typedef CallBackVersion = void Function(bool isSuccess, int version);

/// 三路最大功率类型
enum ThreeWayFrequencyType { one, two, three }

/// 三路最大脉宽类型
enum ThreeWayPulseWidthType { one, two, three }

class EmsThreeFuncManager {
  /// 三路获取Mac地址
  static Future<void> getMac() async {
    List<int> getMacAddress = [0xfe, 0x10, 0x00, 0x00];
    try {
      await ConnectManager.getInstance().writeCharacteristic?.write(
          getMacAddress,
          withoutResponse: ConnectManager.getInstance()
              .writeCharacteristic!
              .properties
              .writeWithoutResponse);
    } catch (e) {
      if (kDebugMode) {
        print("Write Error:");
      }
    }
  }

  /// 三路获取设备状态
  static Future<void> getDeviceStatus(CallBackThree callback) async {
    ConnectManager.getInstance()
        .eventBus
        .on<ThreeDeviceStatus>()
        .listen((event) {
      callback(true, event);
    });

    List<int> getPower = [0xfe, 0x14, 0x00, 0x00];
    try {
      await ConnectManager.getInstance().writeCharacteristic?.write(getPower,
          withoutResponse: ConnectManager.getInstance()
              .writeCharacteristic!
              .properties
              .writeWithoutResponse);
    } catch (e) {
      if (kDebugMode) {
        print("Write Error:");
      }
      callback(false, ThreeDeviceStatus());
    }
  }

  /// 三路设备 发送工作时间和工作间隔
  static Future<void> sendDurationTime(int durationTime, int intervalTime,
      CallBackWriteStatus callBackWriteStatus) async {
    int valid = (0x00 + durationTime + 0x00 + intervalTime) & 0xff;
    List<int> sentTime = [
      0xfe,
      0x01,
      0x04,
      0x00,
      durationTime,
      0x00,
      intervalTime,
      valid
    ];
    try {
      await ConnectManager.getInstance().writeCharacteristic?.write(sentTime,
          withoutResponse: ConnectManager.getInstance()
              .writeCharacteristic!
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

  /// 三路设备 发送剩余时间
  static Future<void> sendRemainingTime(
      int remainTime, CallBackWriteStatus callBackWriteStatus) async {
    int valid = remainTime & 0xff;
    List<int> sentTime = [0xfe, 0x04, 0x01, remainTime, valid];
    try {
      await ConnectManager.getInstance().writeCharacteristic?.write(sentTime,
          withoutResponse: ConnectManager.getInstance()
              .writeCharacteristic!
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

  /// 三路设备 设置一二三路最大与最小功率
  static Future<void> sendFrequencyMax(ThreeWayFrequencyType threeWayType,
      int max, int min, CallBackWriteStatus callBackWriteStatus) async {
    int valid = ((max >> 24) &
            0xff + (max >> 16) &
            0xff + (max >> 8) &
            0xff + max &
            0xff + (min >> 24) &
            0xff + (min >> 16) &
            0xff + (min >> 8) &
            0xff + min &
            0xff) &
        0xff;
    int instructions = 0x00;
    switch (threeWayType) {
      case ThreeWayFrequencyType.one:
        instructions = 0x05;
        break;
      case ThreeWayFrequencyType.two:
        instructions = 0x0c;
        break;
      case ThreeWayFrequencyType.three:
        instructions = 0x0d;
        break;
    }
    List<int> sentFrequency = [
      0xfe,
      instructions,
      0x08,
      (max >> 24),
      (max >> 16),
      (max >> 8),
      max,
      (min >> 24),
      (min >> 16),
      (min >> 8),
      min,
      valid
    ];
    try {
      await ConnectManager.getInstance().writeCharacteristic?.write(
          sentFrequency,
          withoutResponse: ConnectManager.getInstance()
              .writeCharacteristic!
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

  /// 三路设备 设置一二三路最大与最小脉宽
  static Future<void> sendPulseWidthMax(ThreeWayPulseWidthType threeWayType,
      int max, int min, CallBackWriteStatus callBackWriteStatus) async {
    int valid = ((max >> 24) &
            0xff + (max >> 16) &
            0xff + (max >> 8) &
            0xff + max &
            0xff + (min >> 24) &
            0xff + (min >> 16) &
            0xff + (min >> 8) &
            0xff + min &
            0xff) &
        0xff;
    int instructions = 0x00;
    switch (threeWayType) {
      case ThreeWayPulseWidthType.one:
        instructions = 0x06;
        break;
      case ThreeWayPulseWidthType.two:
        instructions = 0x0e;
        break;
      case ThreeWayPulseWidthType.three:
        instructions = 0x0f;
        break;
    }
    List<int> sentFrequency = [
      0xfe,
      instructions,
      0x08,
      (max >> 24),
      (max >> 16),
      (max >> 8),
      max,
      (min >> 24),
      (min >> 16),
      (min >> 8),
      min,
      valid
    ];
    try {
      await ConnectManager.getInstance().writeCharacteristic?.write(
          sentFrequency,
          withoutResponse: ConnectManager.getInstance()
              .writeCharacteristic!
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

  /// 下发三路强度
  static Future<void> sendStrength(int one, int two, int three,
      CallBackWriteStatus callBackWriteStatus) async {
    int valid = (one + two + three) & 0xff;
    List<int> sendStrength = [0xfe, 0x08, 0x03, one, two, three, valid];
    try {
      await ConnectManager.getInstance().writeCharacteristic?.write(
          sendStrength,
          withoutResponse: ConnectManager.getInstance()
              .writeCharacteristic!
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

  /// 获取版本号
  static Future<void> sendGetVersion(CallBackVersion callBackVersion) async {
    ConnectManager.getInstance().versionEventBus.on<int>().listen((event) {
      callBackVersion(true, event);
    });

    List<int> sendStrength = [0xfe, 0x0b, 0x00, 0x00];
    try {
      await ConnectManager.getInstance().writeCharacteristic?.write(
          sendStrength,
          withoutResponse: ConnectManager.getInstance()
              .writeCharacteristic!
              .properties
              .writeWithoutResponse);
    } catch (e) {
      if (kDebugMode) {
        print("Write Error:");
      }
      callBackVersion(false, 0);
    }
  }

  /// 下发 开始1 暂停 2 停止 0
  static Future<void> sendStart(
      int start, CallBackWriteStatus callBackWriteStatus) async {
    int valid = start & 0xff;
    List<int> sendStrength = [0xfe, 0x16, 0x01, start, valid];
    try {
      await ConnectManager.getInstance().writeCharacteristic?.write(
          sendStrength,
          withoutResponse: ConnectManager.getInstance()
              .writeCharacteristic!
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

  /// 设置名字
  static Future<void> sendSetName(
      List<int> name, CallBackWriteStatus callBackWriteStatus) async {
    if (name.isEmpty || name.length > 10) {
      callBackWriteStatus(false);
    }
    List<int> sendSetName = [0xfe, 0x20, 0x0a];
    int num = 0;
    for (var element in name) {
      num = num + element;
      sendSetName.add(element);
    }
    int valid = num & 0xff;
    sendSetName.add(valid);
    if (kDebugMode) {
      print("设置名字结果:$sendSetName");
    }
    try {
      await ConnectManager.getInstance().writeCharacteristic?.write(sendSetName,
          withoutResponse: ConnectManager.getInstance()
              .writeCharacteristic!
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
}
