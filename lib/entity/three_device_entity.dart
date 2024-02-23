import 'package:flutter_blue_plus/flutter_blue_plus.dart';
class ThreeDeviceStatus {
  /// 模式 1.捶打 2.按压 3.揉捏 4.推拿 5.自定义
  late int mode;

  /// 开关机状态 1.开机 2.关机
  late int isOn;

  /// 档位 0-100
  late int gear;

  /// 产品类型 0-10（0：未接外设）（1：衣服）（2：提臀短裤）2K（3：腰带）500欧姆（4：背心）5K （......预留）
  late int type;

  /// 电量
  late int power;
}
