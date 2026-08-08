import 'package:flutter_test/flutter_test.dart';
import 'package:gitquest/features/tools/data/tool_content.dart';

void main() {
  test('fournit trente situations et trente définitions locales', () {
    expect(commandReferences, hasLength(30));
    expect(glossaryEntries, hasLength(30));
    expect(
      commandReferences.map((entry) => entry.command).toSet(),
      hasLength(commandReferences.length),
    );
    expect(
      glossaryEntries.map((entry) => entry.term).toSet(),
      hasLength(glossaryEntries.length),
    );
  });

  test('retrouve une commande à partir de son intention', () {
    final results = commandReferences
        .where((entry) => entry.searchableText.contains('sans perdre'))
        .toList();

    expect(results, hasLength(1));
    expect(results.single.command, 'git reset --soft HEAD~1');
    expect(results.single.risk, CommandRisk.caution);
  });
}
