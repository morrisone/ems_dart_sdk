import 'dart:async';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../entity/ten_device_entity.dart';
import '../entity/three_device_entity.dart';
import 'ems_const_data.dart';

class ConnectManager {
  // 静态变量，用于保存类的唯一实例
  static ConnectManager? _instance;

  // 私有构造函数，防止外部通过new关键字创建实例
  ConnectManager._internal() {
    // 初始化代码
  }

  static ConnectManager getInstance() {
    // 如果实例不存在，则创建它
    _instance ??= ConnectManager._internal();
    return _instance!;
  }

  ScanResult? currentScanResult;

  /// 服务列表
  late List<BluetoothService> _services = [];

  /// 连接状态
  late BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  /// 连接状态流
  late final StreamController<BluetoothConnectionState>
      _connectionStateSubscription =
      StreamController<BluetoothConnectionState>();

  /// 特征
  BluetoothCharacteristic? characteristic;

  /// 特征1
  BluetoothCharacteristic? writeCharacteristic;

  /// 特征2
  BluetoothCharacteristic? notifyCharacteristic;

  /// 当前连接状态
  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  /// 三路设备状态控制流
  late EventBus eventBus = EventBus();

  /// 三路版本号
  late EventBus versionEventBus = EventBus();

  /// 十路版本号
  late EventBus versionTenEventBus = EventBus();

  /// 十路体脂数据
  late EventBus fatDataTenEventBus = EventBus();

  /// 十路电量
  late EventBus powerTenEventBus = EventBus();

  bool _isCheckFat = false;
  List<int> _fatData = [];

  Future<void> connectToDevice(ScanResult scanResult) async {
    currentScanResult = scanResult;
    // 连接设备
    currentScanResult?.device.connect().then((_) {
      // 连接成功，现在发现服务
      currentScanResult?.device
          .discoverServices()
          .then((List<BluetoothService> services) {
        if (_services.isNotEmpty) {
          _services.clear();
        }
        _services = services;
        // 服务列表已发现
        for (var service in services) {
          if (kDebugMode) {
            print('Service UUID: ${service.uuid}');
            print('preService UUID: ${characteristic?.uuid}');
          }

          /// 分十路和三路处理
          if (scanResult.device.platformName.startsWith("LS ") ||
              scanResult.device.platformName.startsWith("EM")) {
            // 遍历服务的特征
            for (var cystic in service.characteristics) {
              if (kDebugMode) {
                print('Characteristic UUID: ${cystic.uuid}');
              }
              // 处理特征数据，例如读写数据等
              if (cystic.uuid.toString().toUpperCase() ==
                  kCharacteristicsUUID1) {
                writeCharacteristic = cystic;
              } else if (cystic.uuid.toString().toUpperCase() ==
                  kCharacteristicsUUID2) {
                notifyCharacteristic = cystic;
                setNotifyCha(cystic);
              }
            }
          } else {
            // 遍历服务的特征
            for (var cystic in service.characteristics) {
              if (kDebugMode) {
                print('Characteristic UUID: ${cystic.uuid}');
              }
              if (cystic.uuid.toString().toUpperCase() == "FFB2") {
                setNotifyCha(cystic);
                characteristic = cystic;
              }
            }
          }
          _connectionStateSubscription.add(BluetoothConnectionState.connected);
        }
      }).catchError((error) {
        _connectionState = BluetoothConnectionState.disconnected;
        _connectionStateSubscription.add(BluetoothConnectionState.disconnected);
        // 处理发现服务时出现的错误
        if (kDebugMode) {
          print('Error discovering services: $error');
        }
      });
    }).catchError((error) {
      _connectionState = BluetoothConnectionState.disconnected;
      // 处理连接设备时出现的错误
      if (kDebugMode) {
        print('Error connecting to device: $error');
      }
      _connectionState = BluetoothConnectionState.disconnected;
      _connectionStateSubscription.add(BluetoothConnectionState.disconnected);
    });
  }

  // 获取蓝牙连接状态 Stream,作为接口返回出去
  Stream<BluetoothConnectionState> get bleConnectStream =>
      _connectionStateSubscription.stream;

  /// 监听特征值
  void setNotifyCha(BluetoothCharacteristic character) {
    character.setNotifyValue(true).then((_) {
      character.lastValueStream.listen((event) {
        if (kDebugMode) {
          print('received data: $event, cha:${character.uuid.toString()}');
        }
        controlData(event);
      });
    });
  }

  /// 处理返回数据
  void controlData(List<int> list) {
    if (list.isEmpty) {
      return;
    }

    /// 三路设备状态
    if (list[0] == 0xef && list[1] == 0x14) {
      ThreeDeviceStatus three = ThreeDeviceStatus();
      three.mode = list[3];
      three.isOn = list[4];
      three.gear = list[5];
      three.type = list[6];
      three.power = list[7];
      eventBus.fire(three);
      eventBus.destroy();
      eventBus = EventBus();
    }

    /// 三路版本号
    if (list[0] == 0xef && list[1] == 0x0b) {
      versionEventBus.fire(list[3]);
      versionEventBus.destroy();
      versionEventBus = EventBus();
    }

    /// 十路版本号 [59, 0, 10, 0, 47, 85, 1, 3, 205, 10]
    if (list[0] == 0x3b &&
        list[1] == 0x00 &&
        list[2] == 0x0a &&
        list[3] == 0x00 &&
        list[4] == 0x2f) {
      if (list[5] == 0x55) {
        versionTenEventBus.fire("${list[6]}." "${list[7]}");
      } else {
        versionTenEventBus.fire("");
      }
      versionTenEventBus.destroy();
      versionTenEventBus = EventBus();
    }

    /// 十路电量
    if (list[0] == 0x3b &&
        list[1] == 0x00 &&
        list[2] == 0x0a &&
        list[3] == 0x00 &&
        list[4] == 0x0a) {
      if (list[5] == 0x55) {
        TenDevicePower tenDevicePower = TenDevicePower();
        tenDevicePower.percent = list[6];
        tenDevicePower.mode = list[7];
        powerTenEventBus.fire(tenDevicePower);
      } else {
        powerTenEventBus.fire(TenDevicePower());
      }
      powerTenEventBus.destroy();
      powerTenEventBus = EventBus();
    }

    /// 十路 体脂数据 [59, 0, 12, 0, 12, 68, 40, 168, 27, 1, 131, 10]
    if (list[0] == 0x3b &&
        list[1] == 0x00 &&
        list[2] == 0x0c &&
        list[3] == 0x00 &&
        list[4] == 0x0c) {
      TenFatStatus tenFatStatus = TenFatStatus();
      fatDataTenEventBus.fire(tenFatStatus);
      fatDataTenEventBus.destroy();
      fatDataTenEventBus = EventBus();

      if (list[0] == 0x3b && list[4] == 0x0c && list[5] == 0x00) {
        _isCheckFat = false;
        _fatData = [];
      }

      if (list[0] == 0x3b && list[4] == 0x0c && list[5] == 0x55) {
        _isCheckFat = true;
        _fatData.addAll(list);
      }

      if (_isCheckFat == true) {
        _fatData.addAll(list);
        if (list[16] == 0x0a) {
          _isCheckFat = false;
          TenFatStatus tenFatStatus = TenFatStatus();
          tenFatStatus.isSuccess = true;
          tenFatStatus.data = _fatData;
          fatDataTenEventBus.fire(tenFatStatus);
          fatDataTenEventBus.destroy();
          fatDataTenEventBus = EventBus();
          _fatData = [];
        }
      }
    }
  }
}
