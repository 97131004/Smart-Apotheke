import '../lib/util/helper.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests the main helper functions [parseMid] and [isPureInteger]
/// from the [helper] file.

void main() {
  group('helper.dart', () {
    /// Testing [parseMid]. Parses middle string from input string [source] 
    /// between [delim1] and [delim2].
    group('[testing parseMid]', () {
      test('with string', () async {
        String out = Helper.parseMid('</div>work<div>', '</div>', '<div>');
        expect(out, 'work');
      });
      test('with string and identical delimiter strings', () async {
        String out = Helper.parseMid('<div>nice<div>', '<div>', '<div>');
        expect(out, 'nice');
      });
      test('with empty string', () async {
        String out = Helper.parseMid('', '</div>', '<div>');
        expect(out, '');
      });
      test('with string and non-zero start index', () async {
        String out = Helper.parseMid(
            '<div>must</div>work<div>well</div>', '<div>', '</div>', 14);
        expect(out, 'well');
      });
      test('with string and a start index that exceeds the input text length',
          () async {
        String out = Helper.parseMid('<', '<div>', '</div>', 100);
        expect(out, '');
      });
      test('with empty string and non-zero start index', () async {
        String out = Helper.parseMid('', '<div>', '</div>', 14);
        expect(out, '');
      });
    });
    /// Testing [isPureInteger]. Checks whether input string [s] is a pure 
    /// integer (only includes numbers 0 to 9).
    group('[testing isPureInteger]', () {
      test('testing isPureInteger with letters', () async {
        expect(Helper.isPureInteger('text'), false);
      });
      test('testing isPureInteger with minus sign', () async {
        expect(Helper.isPureInteger('-123'), false);
      });
      test('testing isPureInteger with double', () async {
        expect(Helper.isPureInteger('123.567'), false);
      });
      test('testing isPureInteger with plus sign', () async {
        expect(Helper.isPureInteger('+123'), false);
      });
      test('testing isPureInteger with integer', () async {
        expect(Helper.isPureInteger('123'), true);
      });
      test('testing isPureInteger with integer with leading zeros', () async {
        expect(Helper.isPureInteger('00012345'), true);
      });
    });
  });
}
