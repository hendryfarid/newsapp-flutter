import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const String _bookmarkKey = 'bookmarked_articles';
  static final BookmarkService _instance = BookmarkService._internal();
  late SharedPreferences _prefs;

  factory BookmarkService() {
    return _instance;
  }

  BookmarkService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<Map<String, dynamic>>> getBookmarkedArticles() async {
    final String? bookmarksJson = _prefs.getString(_bookmarkKey);
    if (bookmarksJson == null) return [];

    final List<dynamic> decoded = json.decode(bookmarksJson);
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<bool> isArticleBookmarked(String url) async {
    final bookmarks = await getBookmarkedArticles();
    return bookmarks.any((article) => article['url'] == url);
  }

  Future<void> toggleBookmark(Map<String, dynamic> article) async {
    final bookmarks = await getBookmarkedArticles();
    final url = article['url'];

    if (bookmarks.any((a) => a['url'] == url)) {
      // Remove bookmark
      bookmarks.removeWhere((a) => a['url'] == url);
    } else {
      // Add bookmark
      bookmarks.add(article);
    }

    await _prefs.setString(_bookmarkKey, json.encode(bookmarks));
  }

  Future<void> removeBookmark(String url) async {
    final bookmarks = await getBookmarkedArticles();
    bookmarks.removeWhere((article) => article['url'] == url);
    await _prefs.setString(_bookmarkKey, json.encode(bookmarks));
  }
}
