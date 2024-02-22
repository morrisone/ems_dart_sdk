import 'dart:core';

class TenDevicePower {
  /// 百分比
  late int percent;

  /// 状态
  late int mode;
}

class TenFatStatus {
  bool isSuccess = false;
  List<int> data = [];
}

class EMSReportModel {
  late int obesity; //肥胖度
  late int bmi;
  late double bmc; //骨盐量
  late double bfr; //体脂率
  late double fatMass; //脂肪重量
  late int skeletalMuscleRate; //骨骼肌率
  late double skeletalMuscleWeight; //骨骼肌重量
  late int muscleRate; //肌肉率
  late double muscleWeight; //肌肉重量
  late double visceralFat; //内脏脂肪
  late double moisture; //体水分率
  late double waterContent; //含水量
  late int basicMetabolism; //基础代谢
  late int boneMass; //骨重
  late double protein; //蛋白质
  late int physicalAge; //身体年龄
  late double whr; //腰臀比
  late double ffm; //去脂体重
  late double bodyFat; //躯干脂肪
  late double leftArmFat; //左上肢脂肪
  late double rightArmFat; //右上肢脂肪
  late double leftLegFat; //左下肢脂肪
  late double rightLegFat; //右下肢脂肪
  late double bodyMuscle; //躯干肌肉
  late double leftArmMuscle; //左上肢肌肉
  late double rightArmMuscle; //右上肢肌肉
  late double leftLegMuscle; //左下肢肌肉
  late double rightLegMuscle; //右下肢肌肉
  late int created;

  static EMSReportModel getFrom(List<int> bytes, double weight) {
    EMSReportModel reportModel = EMSReportModel();
    // 肌肉重*10
    int value = (bytes[9] << 8 | bytes[10]);
    reportModel.muscleWeight = value.toDouble() / 10.0;

    //骨盐量*10
    int boneSalt = (bytes[21] << 8 | bytes[22]);
    reportModel.bmc = boneSalt.toDouble() / 10.0;

    //骨骼肌重*10
    int boneWeight = bytes[23] << 8 | bytes[24];
    reportModel.skeletalMuscleWeight = boneWeight.toDouble() / 10.0;

    //蛋白质率*10
    int protein = bytes[25] << 8 | bytes[26];
    reportModel.protein = protein.toDouble() / 10.0;

    //基础代谢
    int metabolism = bytes[29] << 8 | bytes[30];
    reportModel.basicMetabolism = metabolism;

    //体脂百分比*10
    int bodyFatRate = bytes[31] << 8 | bytes[32];
    reportModel.bfr = bodyFatRate.toDouble() / 10.0;

    //体水分率*10
    int waterContentRate = bytes[33] << 8 | bytes[34];
    reportModel.moisture = waterContentRate.toDouble() / 10.0;

    //内脏脂肪等级*10
    int visceralFat = bytes[37] << 8 | bytes[38];
    reportModel.visceralFat = visceralFat.toDouble() / 10.0;

    //身体年龄
    reportModel.physicalAge = bytes[39];

    //身体评分
    // NSInteger bodyScore = bytes[40];
    //肌肉控制X10
    // NSInteger muscleControl = bytes[45] + bytes[46];
    //体重控制X10
    // NSInteger weightControl = bytes[47] + bytes[48];
    //脂肪控制X10
    // NSInteger fatControl = bytes[49] + bytes[50];

    //躯干脂肪率X10
    int bodyRate = bytes[53] << 8 | bytes[54];
    reportModel.bodyFat = bodyRate.toDouble() / 10.0;

    //右手脂肪率X10
    int rightArmFatRate = bytes[55] << 8 | bytes[56];
    reportModel.rightArmFat = rightArmFatRate.toDouble() / 10.0;

    //左手脂肪率X10
    int leftArmFatRate = bytes[57] << 8 | bytes[58];
    reportModel.leftArmFat = leftArmFatRate.toDouble() / 10.0;

    //右脚脂肪率X10
    int rightLegFatRate = bytes[59] << 8 | bytes[60];
    reportModel.rightLegFat = rightLegFatRate.toDouble() / 10.0;

    //左脚脂肪率X10
    int leftLegFatRate = bytes[61] << 8 | bytes[62];
    reportModel.leftLegFat = leftLegFatRate.toDouble() / 10.0;

    //躯干肌肉率X10
    int bodyMuscleRate = bytes[63] << 8 | bytes[64];
    reportModel.bodyMuscle = bodyMuscleRate.toDouble() / 10.0;

    //右手肌肉率X10
    int rightArmMuscleRate = bytes[65] << 8 | bytes[66];
    reportModel.rightArmMuscle = rightArmMuscleRate.toDouble() / 10.0;

    //左手肌肉率X10
    int leftArmMuscleRate = bytes[67] << 8 | bytes[68];
    reportModel.leftArmMuscle = leftArmMuscleRate.toDouble() / 10.0;

    //右脚肌肉率X10
    int rightLegMuscleRate = bytes[69] << 8 | bytes[70];
    reportModel.rightLegMuscle = rightLegMuscleRate.toDouble() / 10.0;

    //左脚肌肉率X10
    int leftLegMuscleRate = bytes[71] << 8 | bytes[72];
    reportModel.leftLegMuscle = leftLegMuscleRate.toDouble() / 10.0;

    //腰臀比*100
    int whr = bytes[81] << 8 | bytes[82];
    reportModel.whr = whr / 100.0;

    reportModel.fatMass = weight * (reportModel.bfr.toDouble() / 100);
    reportModel.ffm = weight - reportModel.fatMass;
    reportModel.waterContent = weight * (reportModel.moisture.toDouble() / 100);
    reportModel.boneMass = 0;
    reportModel.skeletalMuscleRate = 0;
    reportModel.muscleRate = 0;
    reportModel.obesity = 0;

    return reportModel;
  }
}
