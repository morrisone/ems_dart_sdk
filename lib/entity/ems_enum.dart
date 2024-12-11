enum ReceiveType {
  canStart, // 可以开始
  tenNeedStart, // 十路 需要启动
  tenNeedEnd, // 十路 需要结束
  tenHasPaused, // 十路 已经暂停
  tenHasResume, // 十路 已经暂停
  tenHasSending, // 十路 输出开始

  threeNeedFirstFrequency, // 需要发送第一路频率
  threeNeedWorkTime, // 需要发送工作时间
  threeNeedSecondFrequency, // 需要发送第二路频率
  threeNeedThirdFrequency, // 需要发送第三路频率

  threeNeedFirstPlusWidth, // 需要发送第一路脉宽
  threeNeedSecondPlusWidth, // 需要发送第二路脉宽
  threeNeedThirdPlusWidth, // 需要发送第三路脉宽
  threeNeedCycleTime, // 需要发送周期时间

  threeStart, // 三路 已开启
  threeEnd, // 三路 已结束
  threePaused, // 三路 已经暂停

}