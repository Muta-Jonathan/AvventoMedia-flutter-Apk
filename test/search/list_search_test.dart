import 'package:avvento_media/search/group_search.dart';
import 'package:avvento_media/search/highlight.dart';
import 'package:avvento_media/search/list_search_controller.dart';
import 'package:avvento_media/search/search_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class Item {
  const Item(this.title, {this.daysAgo, this.minutes});
  final String title;
  final int? daysAgo;
  final int? minutes;
}

final now = DateTime(2026, 10, 20);

List<String> run(List<Item> items, ListSearchController search) =>
    ListRanker.apply<Item>(
      items,
      search,
      titleOf: (i) => i.title,
      dateOf: (i) =>
          i.daysAgo == null ? null : now.subtract(Duration(days: i.daysAgo!)),
      durationOf: (i) =>
          i.minutes == null ? null : Duration(minutes: i.minutes!),
    ).map((i) => i.title).toList();

void main() {
  const items = [
    Item('Night 1 · Daniel 2: The Dream of Kingdoms', daysAgo: 30, minutes: 72),
    Item('Night 2 · The Little Horn of Daniel 7', daysAgo: 29, minutes: 58),
    Item('Questions on Daniel and Revelation', daysAgo: 25, minutes: 42),
    Item('Daniel’s Prayer', daysAgo: 20, minutes: 7),
    Item('Youth Hour · Dare to Be a Daniel', daysAgo: 22, minutes: 19),
    Item('Praise and Worship Night', daysAgo: 10, minutes: 90),
  ];

  group('ListRanker.score', () {
    test('every word must be in the title', () {
      expect(ListRanker.score('Little Horn of Daniel 7', 'daniel horn'),
          greaterThan(0));
      expect(ListRanker.score('Little Horn of Daniel 7', 'daniel kato'), 0);
    });

    test('starts with beats a whole word beats a prefix', () {
      expect(ListRanker.score('Daniel Speaks', 'daniel'), 3);
      expect(ListRanker.score('The Book of Daniel', 'daniel'), 2);
      expect(ListRanker.score('Danielle Smith', 'daniel'), 3);
      expect(ListRanker.score('Dare to Be a Danielite', 'daniel'), 1);
    });

    test('ignores case, accents and apostrophes', () {
      expect(ListRanker.score('Eriiso Ly’Obunnabbi', 'lyobunnabbi'),
          greaterThan(0));
      expect(ListRanker.score('Café Talks', 'cafe'), greaterThan(0));
      expect(ListRanker.score('DANIEL', 'daniel'), greaterThan(0));
    });
  });

  group('ListRanker.apply', () {
    test('no query keeps the page order', () {
      expect(run(items, ListSearchController()), items.map((i) => i.title));
    });

    test('keeps matches, best first, newest among equals', () {
      final s = ListSearchController()..query = 'daniel';
      expect(run(items, s), [
        'Daniel’s Prayer', // Starts with it.
        // Then whole words, newest first.
        'Youth Hour · Dare to Be a Daniel',
        'Questions on Daniel and Revelation',
        'Night 2 · The Little Horn of Daniel 7',
        'Night 1 · Daniel 2: The Dream of Kingdoms',
      ]);
    });

    test('newest and oldest sort by date', () {
      final s = ListSearchController()
        ..query = 'daniel'
        ..sort = ListSort.newest;
      expect(run(items, s).first, 'Daniel’s Prayer');
      s.sort = ListSort.oldest;
      expect(run(items, s).first, 'Night 1 · Daniel 2: The Dream of Kingdoms');
    });

    test('sorting works without a query too', () {
      final s = ListSearchController()..sort = ListSort.newest;
      expect(run(items, s).first, 'Praise and Worship Night');
    });

    test('length keeps only what fits, and items without one are dropped', () {
      final s = ListSearchController()..length = LengthFilter.over60;
      expect(run(items, s), [
        'Night 1 · Daniel 2: The Dream of Kingdoms',
        'Praise and Worship Night',
      ]);
      expect(run([const Item('No length')], s), isEmpty);
    });

    test('query and length together', () {
      final s = ListSearchController()
        ..query = 'daniel'
        ..length = LengthFilter.under20;
      expect(run(items, s),
          ['Daniel’s Prayer', 'Youth Hour · Dare to Be a Daniel']);
    });
  });

  group('ListSearchController', () {
    test('a list needs more than 8 items to offer search', () {
      final s = ListSearchController();
      expect(s.offersSearch, isFalse);
      s.total = ListSearchController.minItems;
      expect(s.offersSearch, isFalse);
      s.total = ListSearchController.minItems + 1;
      expect(s.offersSearch, isTrue);
    });

    test('open and close; closing drops the query and the choices', () {
      final s = ListSearchController();
      var changes = 0;
      s.addListener(() => changes++);

      s.open();
      s.setQuery('daniel');
      s.setSort(ListSort.newest);
      s.setLength(LengthFilter.mid);
      expect(s.searching && s.hasQuery && s.isRefined, isTrue);

      s.close();
      expect(s.searching, isFalse);
      expect(s.query, '');
      expect(s.sort, ListSort.relevance);
      expect(s.length, LengthFilter.any);
      expect(changes, 5);
    });

    test('setting what is already set does nothing', () {
      final s = ListSearchController();
      var changes = 0;
      s.addListener(() => changes++);
      s.setQuery('');
      s.setSort(ListSort.relevance);
      s.setLength(LengthFilter.any);
      s.close();
      expect(changes, 0);
    });
  });

  group('highlightSpans', () {
    const style = TextStyle(fontSize: 15);
    List<(String, bool)> parts(String text, String query) => [
          for (final s in highlightSpans(text, query,
              style: style, background: Colors.amber))
            (s.text!, s.style!.backgroundColor != null)
        ];

    test('marks every word, whatever the case', () {
      expect(parts('Daniel and the daniel Book', 'DANIEL book'), [
        ('Daniel', true),
        (' and the ', false),
        ('daniel', true),
        (' ', false),
        ('Book', true),
      ]);
    });

    test('no query, or no match, is plain text', () {
      expect(parts('Daniel', ''), [('Daniel', false)]);
      expect(parts('Daniel', 'zzz'), [('Daniel', false)]);
    });

    test('regular-expression characters in the query are just text', () {
      expect(parts('a (b) c', '(b)'),
          [('a ', false), ('(b)', true), (' c', false)]);
      expect(
          () => highlightSpans('x', '[', style: style, background: Colors.red),
          returnsNormally);
    });
  });
}
