import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ems_const_data.dart';

class BleUtil {
  FlutterBluePlus ble = FlutterBluePlus();

  /*
  * 设置日志等级
  * @param level
  * @param color
  * */
  static void emsSetLogLevel(LogLevel level, {color = true}) {
    FlutterBluePlus.setLogLevel(level, color: color);
  }

  /// 当前状态
  static Stream<BluetoothAdapterState> currentState() {
    return FlutterBluePlus.adapterState;
  }
}

class BleScanner {
  //创建一个controller控制流
  final _bleScanController = StreamController<ScanResult?>();

  Future<void> startBleScan() async {
    //把扫描结果添加到流里面
    FlutterBluePlus.scanResults.listen((event) {
      for (ScanResult element in event) {
        if (element.device.advName == kEMSClothBLEName ||
            element.device.advName == "JYSX_CY" ||
            element.device.advName == "GOSO" ||
            element.device.advName == "GAOSO" ||
            element.device.advName.startsWith("YDSC") ||
            element.device.advName.startsWith("LS ") ||
            element.device.advName.startsWith("EMA") ||
            element.device.advName.startsWith("EM")) {
          _bleScanController.add(element);
        }
      }
    });
    await FlutterBluePlus.startScan(withServices: [
      // Guid.fromString(kServiceUUID),
      // Guid.fromString(kServiceUUID1)
    ], timeout: const Duration(seconds: 10));
  }

  //停止扫描接口
  Future<void> stopBleScan() async {
    await FlutterBluePlus.stopScan();
  }

  // 获取蓝牙扫描结果的 Stream,作为接口返回出去
  Stream<ScanResult?> get bleScanStream => _bleScanController.stream;
}
