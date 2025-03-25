import 'package:flutter_client_sse/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Utils tests.', () {
    test('Should generate random jitter', () {
      for (var i = 0; i < 100; i++) {
        var result = Utils.jitter(1000, 0.25);
        assert(result > 749);
        assert(result < 1000);
      }
    });

    test('Should generate Exp Backoff no Jitter', () {
      const expected = [
        [0, 10],
        [1, 20],
        [2, 40],
        [3, 80],
        [4, 160],
        [5, 320],
        [6, 640],
        [7, 1280],
        [8, 2560],
        [9, 5120],
        [10, 6000],
        [11, 6000],
      ];

      for (final e in expected) {
        var result = Utils.expBackoff(10, 6000, e[0]);
        assert(result == e[1]);
      }
    });

    test('Should generate Exp Backoff with Jitter', () {
      const expected = [
        [0, 10],
        [1, 20],
        [2, 40],
        [3, 80],
        [4, 160],
        [5, 320],
        [6, 640],
        [7, 1280],
        [8, 2560],
        [9, 5120],
        [10, 6000],
        [11, 6000],
      ];

      var jitterFactor = 0.25;
      int jitterFn(int num) => Utils.jitter(num, jitterFactor);

      for (final e in expected) {
        var result = Utils.expBackoff(10, 6000, e[0], jitterFn);
        assert(result > (e[1] * (1 - jitterFactor)) - 1);
        assert(result < e[1]);
      }
    });
  });
}
