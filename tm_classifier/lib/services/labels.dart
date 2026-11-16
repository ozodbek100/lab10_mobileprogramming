/// "0 Mug\n1 Bottle\n" becomes ['Mug', 'Bottle'].
///
/// Pure function: no Flutter, no TensorFlow, so it is easy to unit test.
List<String> parseLabels(String raw) => [
      for (final line in raw.split('\n'))
        if (line.trim().isNotEmpty)
          line.trim().replaceFirst(RegExp(r'^\d+\s+'), ''),
    ];