import '../models/radiomodel/podcast_episode_model.dart';
import 'app_constants.dart';
import 'episode_order.dart';

/// How a podcast's episodes are laid out.
enum FeedKind {
  /// "Genesis 1"…: grouped by book with a book jump.
  bible,

  /// An Ellen G. White book read chapter by chapter.
  egwBook,

  /// Numbered parts ("Pt. 3", "Ch. 2"), played in order.
  series,

  /// Daily and weekly shows, newest first.
  show,
}

class BibleBook {
  const BibleBook(this.name, this.chapters);
  final String name;
  final int chapters;
}

/// The 66 books in canonical order; AzuraCast's season number on the Bible
/// shows is the 1-based index into this list.
const bibleBooks = <BibleBook>[
  BibleBook('Genesis', 50),
  BibleBook('Exodus', 40),
  BibleBook('Leviticus', 27),
  BibleBook('Numbers', 36),
  BibleBook('Deuteronomy', 34),
  BibleBook('Joshua', 24),
  BibleBook('Judges', 21),
  BibleBook('Ruth', 4),
  BibleBook('1 Samuel', 31),
  BibleBook('2 Samuel', 24),
  BibleBook('1 Kings', 22),
  BibleBook('2 Kings', 25),
  BibleBook('1 Chronicles', 29),
  BibleBook('2 Chronicles', 36),
  BibleBook('Ezra', 10),
  BibleBook('Nehemiah', 13),
  BibleBook('Esther', 10),
  BibleBook('Job', 42),
  BibleBook('Psalms', 150),
  BibleBook('Proverbs', 31),
  BibleBook('Ecclesiastes', 12),
  BibleBook('Song of Solomon', 8),
  BibleBook('Isaiah', 66),
  BibleBook('Jeremiah', 52),
  BibleBook('Lamentations', 5),
  BibleBook('Ezekiel', 48),
  BibleBook('Daniel', 12),
  BibleBook('Hosea', 14),
  BibleBook('Joel', 3),
  BibleBook('Amos', 9),
  BibleBook('Obadiah', 1),
  BibleBook('Jonah', 4),
  BibleBook('Micah', 7),
  BibleBook('Nahum', 3),
  BibleBook('Habakkuk', 3),
  BibleBook('Zephaniah', 3),
  BibleBook('Haggai', 2),
  BibleBook('Zechariah', 14),
  BibleBook('Malachi', 4),
  BibleBook('Matthew', 28),
  BibleBook('Mark', 16),
  BibleBook('Luke', 24),
  BibleBook('John', 21),
  BibleBook('Acts', 28),
  BibleBook('Romans', 16),
  BibleBook('1 Corinthians', 16),
  BibleBook('2 Corinthians', 13),
  BibleBook('Galatians', 6),
  BibleBook('Ephesians', 6),
  BibleBook('Philippians', 4),
  BibleBook('Colossians', 4),
  BibleBook('1 Thessalonians', 5),
  BibleBook('2 Thessalonians', 3),
  BibleBook('1 Timothy', 6),
  BibleBook('2 Timothy', 4),
  BibleBook('Titus', 3),
  BibleBook('Philemon', 1),
  BibleBook('Hebrews', 13),
  BibleBook('James', 5),
  BibleBook('1 Peter', 5),
  BibleBook('2 Peter', 3),
  BibleBook('1 John', 5),
  BibleBook('2 John', 1),
  BibleBook('3 John', 1),
  BibleBook('Jude', 1),
  BibleBook('Revelation', 22),
];

/// Books 1–39 are the Old Testament.
const oldTestamentBooks = 39;

final Map<String, int> _bookIndex = {
  for (var i = 0; i < bibleBooks.length; i++)
    bibleBooks[i].name.toLowerCase(): i + 1,
  'psalm': 19,
  'song of songs': 22,
  'revelations': 66,
};

final _bibleTitle = RegExp(r'^\s*(.+?)\s+(\d+)\s*$');

/// A chapter of the Bible: [book] is 1-based into [bibleBooks].
class BibleRef {
  const BibleRef(this.book, this.chapter);
  final int book;
  final int chapter;

  BibleBook get bibleBook => bibleBooks[book - 1];
  bool get newTestament => book > oldTestamentBooks;
}

/// "Genesis 1" → Genesis, chapter 1. Null for anything else.
BibleRef? bibleRef(PodcastEpisode e) {
  final m = _bibleTitle.firstMatch(e.title);
  if (m == null) return null;
  final book = _bookIndex[m.group(1)!.toLowerCase()];
  if (book == null) return null;
  return BibleRef(book, int.parse(m.group(2)!));
}

const _egwBooks = [
  'patriarchs and prophets',
  'desire of ages',
  'great controversy',
  'prophets and kings',
  'acts of the apostles',
  'steps to christ',
  "christ's object lessons",
  'ministry of healing',
  'mount of blessing',
  'early writings',
  'story of redemption',
];

final _chapterTitle = RegExp(r'^\s*ch(?:apter|\.)?\s*\d', caseSensitive: false);

/// Bible when most titles are `Book chapter`; an Ellen G. White book
/// when the show is one and its episodes are chapters; then numbered
/// series; otherwise a regular show.
FeedKind feedKindOf(String showTitle, List<PodcastEpisode> episodes) {
  if (episodes.isEmpty) return FeedKind.show;
  final bible = episodes.where((e) => bibleRef(e) != null).length;
  if (bible >= episodes.length * 0.8) return FeedKind.bible;

  final title = showTitle.toLowerCase();
  final chapters = episodes.where((e) => _chapterTitle.hasMatch(e.title));
  if (_egwBooks.any(title.contains) &&
      chapters.length >= episodes.length * 0.6) {
    return FeedKind.egwBook;
  }
  if (_inOrderShows.any(title.contains)) return FeedKind.series;
  if (_newestShows.any(title.contains)) return FeedKind.show;
  return looksLikeSeries(episodes) ? FeedKind.series : FeedKind.show;
}

/// Shows whose titles don't say how they play, matched by show title.
const _inOrderShows = ["children's bible journey", 'manya baibuli'];

/// Several stories in parts ("Edison's Story, Part 1"): sorting by part
/// would mix the stories.
const _newestShows = ['rendezvous'];

/// Series, Bible and books start in order; shows start newest first.
EpisodeSort defaultSort(FeedKind kind) =>
    kind == FeedKind.show ? EpisodeSort.newest : EpisodeSort.inOrder;

/// Row title: EGW chapters drop the repeated "(Book)" and use an en dash,
/// so "Ch. 1 - Why Was Sin Permitted (Patriarchs and Prophets)" reads
/// "Ch. 1 – Why Was Sin Permitted".
String episodeDisplayTitle(PodcastEpisode e, FeedKind kind) {
  if (kind != FeedKind.egwBook) return e.title;
  return e.title
      .replaceFirst(RegExp(r'\s*\([^()]*\)\s*$'), '')
      .replaceFirstMapped(
          RegExp(r'^(\s*ch\.?\s*\d+)\s+-\s+', caseSensitive: false),
          (m) => '${m[1]} – ');
}

/// Overline lead for a row shown in order: "Chapter 3" for the Bible and
/// books, "Part 3" (or "Chapter 3") for series; null shows the date.
String? episodeNumberLead(PodcastEpisode e, FeedKind kind) {
  switch (kind) {
    case FeedKind.bible:
      final ref = bibleRef(e);
      return ref == null ? null : '${AppConstants.chapter} ${ref.chapter}';
    case FeedKind.egwBook:
      final n = seriesNumber(e);
      return n == null ? null : '${AppConstants.chapter} $n';
    case FeedKind.series:
      final n = seriesNumber(e);
      return n == null ? null : '${seriesNumberLabel(e)} $n';
    case FeedKind.show:
      return null;
  }
}
