library dart_ems_sdk;

export 'ems_ble_util.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
  int getCurrent() {
    return addOne(9);
  }
}
