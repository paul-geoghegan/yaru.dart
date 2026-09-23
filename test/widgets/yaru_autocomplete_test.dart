import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaru/widgets.dart';

const _options = ['apple', 'apricot', 'banana'];

Iterable<String> _optionsBuilder(TextEditingValue value) =>
    _options.where((option) => option.contains(value.text));

Future<void> _pumpAutocomplete(
  WidgetTester tester, {
  YaruAutocomplete<String> autocomplete = const YaruAutocomplete<String>(
    optionsBuilder: _optionsBuilder,
  ),
  TextDirection textDirection = TextDirection.ltr,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Directionality(
        textDirection: textDirection,
        child: Scaffold(body: autocomplete),
      ),
    ),
  );
}

Future<CapturedAccessibilityAnnouncement> _announcementFor(
  WidgetTester tester,
  String text,
) async {
  tester.takeAnnouncements();
  await tester.enterText(find.byType(TextFormField), text);
  await tester.pump();
  return tester.takeAnnouncements().last;
}

void main() {
  testWidgets('announces default English messages', (tester) async {
    await _pumpAutocomplete(tester);

    var announcement = await _announcementFor(tester, 'ap');
    expect(announcement.message, '2 options available');
    expect(announcement.textDirection, TextDirection.ltr);

    announcement = await _announcementFor(tester, 'b');
    expect(announcement.message, '1 option available');

    announcement = await _announcementFor(tester, 'zzz');
    expect(announcement.message, 'No options found');

    announcement = await _announcementFor(tester, '');
    expect(announcement.message, 'Input cleared');
  });

  testWidgets('announces custom messages', (tester) async {
    await _pumpAutocomplete(
      tester,
      autocomplete: YaruAutocomplete<String>(
        optionsBuilder: _optionsBuilder,
        clearedAnnouncement: 'cleared',
        noOptionsAnnouncement: 'nothing',
        optionsCountAnnouncement: (count) => 'count $count',
      ),
    );

    expect((await _announcementFor(tester, 'ap')).message, 'count 2');
    expect((await _announcementFor(tester, 'zzz')).message, 'nothing');
    expect((await _announcementFor(tester, '')).message, 'cleared');
  });

  testWidgets('uses the ambient text direction by default', (tester) async {
    await _pumpAutocomplete(tester, textDirection: TextDirection.rtl);

    final announcement = await _announcementFor(tester, 'ap');
    expect(announcement.textDirection, TextDirection.rtl);
  });

  testWidgets('announcementTextDirection overrides the ambient direction', (
    tester,
  ) async {
    await _pumpAutocomplete(
      tester,
      autocomplete: const YaruAutocomplete<String>(
        optionsBuilder: _optionsBuilder,
        announcementTextDirection: TextDirection.ltr,
      ),
      textDirection: TextDirection.rtl,
    );

    final announcement = await _announcementFor(tester, 'ap');
    expect(announcement.textDirection, TextDirection.ltr);
  });
}
