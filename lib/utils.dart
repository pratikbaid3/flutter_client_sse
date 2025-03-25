import 'dart:math';

class Utils {
  static int _defaultJitterFn(int num) => num;

  static int jitter(int baseTime, double randomFactor) {
    var rest = baseTime * randomFactor;
    var rng = Random();
    var jitter = (baseTime - rest) + rng.nextDouble() * rest;

    return jitter.toInt();
  }

  static int expBackoff(
    int initial,
    int max,
    int actualRetry, [
    Function? jitterFn,
  ]) {
    Function curatedFn;
    curatedFn = jitterFn ?? _defaultJitterFn;
    var base = initial << actualRetry;
    var willWait = 0;
    var isOverflowing = base <= 0;
    willWait = (base > max || isOverflowing) ? curatedFn(max) : curatedFn(base);

    return willWait.toInt();
  }

  static String? checkString(String data) {
    var trim = data.trim();

    return trim.isEmpty ? '' : trim;
  }
}
