  import 'package:flutter_test/flutter_test.dart';
import 'package:tm_classifier/services/labels.dart';

void main() {
  test('normal case', () {
    expect(parseLabels('0 Mug\n1 Bottle\n'), ['Mug', 'Bottle']);
  });

  test('Windows line endings, trailing blank line, label with a space', () {
    expect(
      parseLabels('0 Mug\r\n1 Bottle\r\n2 Car keys\r\n\r\n'),
      ['Mug', 'Bottle', 'Car keys'],
    );
  });
}