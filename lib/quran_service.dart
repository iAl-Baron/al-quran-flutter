import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranSurah {
  final int number;
  final String name;
  final String englishName;
  final int numberOfAyahs;
  final String revelationType;

  const QuranSurah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  factory QuranSurah.fromJson(Map<String, dynamic> json) => QuranSurah(
        number: json['number'] as int,
        name: json['name'] as String,
        englishName: json['englishName'] as String,
        numberOfAyahs: json['numberOfAyahs'] as int,
        revelationType: json['revelationType'] as String,
      );
}

class QuranAyah {
  final int number;
  final int numberInSurah;
  final String text;

  const QuranAyah({
    required this.number,
    required this.numberInSurah,
    required this.text,
  });

  factory QuranAyah.fromJson(Map<String, dynamic> json) => QuranAyah(
        number: json['number'] as int,
        numberInSurah: json['numberInSurah'] as int,
        text: json['text'] as String,
      );
}

class QuranService {
  static const _api = 'https://api.alquran.cloud/v1';
  static const _lastSurahKey = 'quran_last_surah';
  static const _lastAyahKey = 'quran_last_ayah';
  static const _bookmarksKey = 'quran_bookmarks_v1';
  final http.Client _client;

  QuranService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<QuranSurah>> fetchSurahs() async {
    final response = await _client
        .get(Uri.parse('$_api/surah'))
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw const HttpException('تعذّر تحميل قائمة السور');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data
        .map((item) => QuranSurah.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<QuranAyah>> fetchAyahs(int surahNumber) async {
    final cached = await _readCachedSurah(surahNumber);
    if (cached != null) return cached;

    final response = await _client
        .get(Uri.parse('$_api/surah/$surahNumber/quran-uthmani'))
        .timeout(const Duration(seconds: 25));
    if (response.statusCode != 200) {
      throw const HttpException('تعذّر تحميل آيات السورة');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    final rawAyahs = data['ayahs'] as List<dynamic>;
    final ayahs = rawAyahs
        .map((item) => QuranAyah.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
    await _writeCachedSurah(surahNumber, rawAyahs);
    return ayahs;
  }

  Future<File> _cacheFile(int surahNumber) async {
    final root = await getApplicationSupportDirectory();
    final directory = Directory('${root.path}/quran_cache');
    if (!await directory.exists()) await directory.create(recursive: true);
    return File('${directory.path}/surah_$surahNumber.json');
  }

  Future<List<QuranAyah>?> _readCachedSurah(int surahNumber) async {
    try {
      final file = await _cacheFile(surahNumber);
      if (!await file.exists()) return null;
      final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
      return raw
          .map((item) => QuranAyah.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCachedSurah(
      int surahNumber, List<dynamic> rawAyahs) async {
    try {
      final file = await _cacheFile(surahNumber);
      await file.writeAsString(jsonEncode(rawAyahs), flush: true);
    } catch (_) {
      // The online reader remains usable if the device blocks local caching.
    }
  }

  Future<int> getLastSurah() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastSurahKey) ?? 1;
  }

  Future<int> getLastAyah() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastAyahKey) ?? 1;
  }

  Future<void> saveLastRead(int surah, int ayah) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSurahKey, surah);
    await prefs.setInt(_lastAyahKey, ayah);
  }

  Future<Set<String>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_bookmarksKey) ?? <String>[]).toSet();
  }

  Future<bool> toggleBookmark(int surah, int ayah) async {
    final prefs = await SharedPreferences.getInstance();
    final items = (prefs.getStringList(_bookmarksKey) ?? <String>[]).toSet();
    final key = '$surah:$ayah';
    final isNowBookmarked = !items.contains(key);
    if (isNowBookmarked) {
      items.add(key);
    } else {
      items.remove(key);
    }
    await prefs.setStringList(_bookmarksKey, items.toList()..sort());
    return isNowBookmarked;
  }

  Future<bool> isBookmarked(int surah, int ayah) async =>
      (await getBookmarks()).contains('$surah:$ayah');


  String audioUrl(int globalAyahNumber) =>
      'https://cdn.islamic.network/quran/audio/128/ar.abdulbasitmurattal/$globalAyahNumber.mp3';

  Future<File> _audioFile(int globalAyahNumber) async {
    final root = await getApplicationSupportDirectory();
    final directory = Directory('${root.path}/quran_audio/abdulbasit_murattal');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return File('${directory.path}/$globalAyahNumber.mp3');
  }

  Future<File?> getDownloadedAudio(int globalAyahNumber) async {
    try {
      final file = await _audioFile(globalAyahNumber);
      return await file.exists() && await file.length() > 0 ? file : null;
    } catch (_) {
      return null;
    }
  }

  Future<File> downloadAyahAudio(
    int globalAyahNumber, {
    void Function(int received, int total)? onProgress,
  }) async {
    final existing = await getDownloadedAudio(globalAyahNumber);
    if (existing != null) return existing;

    final request = http.Request('GET', Uri.parse(audioUrl(globalAyahNumber)));
    final response = await _client.send(request).timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw HttpException('تعذّر تنزيل ملف التلاوة (${response.statusCode})');
    }
    final total = response.contentLength ?? -1;
    final target = await _audioFile(globalAyahNumber);
    final temporary = File('${target.path}.part');
    var received = 0;
    final sink = temporary.openWrite();
    try {
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(received, total);
      }
      await sink.flush();
      await sink.close();
      if (await temporary.length() == 0) {
        throw const HttpException('ملف الصوت فارغ');
      }
      if (await target.exists()) await target.delete();
      await temporary.rename(target.path);
      return target;
    } catch (_) {
      await sink.close();
      if (await temporary.exists()) await temporary.delete();
      rethrow;
    }
  }

  Future<void> dispose() async => _client.close();
}
