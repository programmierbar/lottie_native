import 'lot_value.dart';

class LOTOpacityValue extends LOTValue {
  late double _value;

  LOTOpacityValue({required double opacity}) {
    _value = opacity;
  }

  String get value {
    return _value.toString();
  }

  String get type {
    return 'LOTOpacityValue';
  }
}
