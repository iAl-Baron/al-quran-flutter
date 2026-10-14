import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'quran_service.dart';

class QuranReaderPage extends StatefulWidget {
  const QuranReaderPage({super.key});

  @override
  State<QuranReaderPage> createState() => _QuranReaderPageState();
}

class _QuranReaderPageState extends State<QuranReaderPage> {
  final QuranService _service = QuranService();
  final AudioPlayer _player = AudioPlayer();
  final TextEditingController _search = TextEditingController();

  List<QuranSurah> _surahs = [];
  List<QuranAyah> _ayahs = [];
  Set<String> _bookmarks = {};
  QuranSurah? _selectedSurah;
  bool _loading = true;
  bool _playing = false;
  String? _error;
  int _currentAyah = 1;
  int _fontSize = 26;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _player.playerStateStream.listen((state) {
      if (mounted) setState(() => _playing = state.playing);
    });
  }

  Future<void> _loadInitial() async {
    try {
      final results = await Future.wait([
        _service.fetchSurahs(),
        _service.getBookmarks(),
        _service.getLastSurah(),
        _service.getLastAyah(),
      ]);
      final surahs = results[0] as List<QuranSurah>;
      final lastSurah = results[2] as int;
      final lastAyah = results[3] as int;
      final selected = surahs.firstWhere(
        (s) => s.number == lastSurah,
        orElse: () => surahs.first,
      );
      if (!mounted) return;
      setState(() {
        _surahs = surahs;
        _bookmarks = results[1] as Set<String>;
        _selectedSurah = selected;
        _currentAyah = lastAyah;
      });
      await _loadSurah(selected, preferredAyah: lastAyah);
    } catch (e) {
      if (mounted) setState(() {
        _loading = false;
        _error = 'تعذّر تحميل القرآن. تحقق من اتصال الإنترنت ثم أعد المحاولة.';
      });
    }
  }

  Future<void> _loadSurah(QuranSurah surah, {int preferredAyah = 1}) async {
    setState(() {
      _loading = true;
      _error = null;
      _selectedSurah = surah;
    });
    try {
      final ayahs = await _service.fetchAyahs(surah.number);
      if (!mounted) return;
      setState(() {
        _ayahs = ayahs;
        _currentAyah = preferredAyah.clamp(1, ayahs.length).toInt();
        _loading = false;
      });
      await _service.saveLastRead(surah.number, _currentAyah);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e is SocketException
            ? 'لا يوجد اتصال، وهذه السورة ليست محفوظة على الجهاز بعد.'
            : 'تعذّر تحميل السورة. حاول مرة أخرى.';
      });
    }
  }

  Future<void> _playAyah(QuranAyah ayah) async {
    final surah = _selectedSurah;
    if (surah == null) return;
    try {
      // Quran audio CDN: Abdul Basit Abdul Samad, Murattal.
      final localAudio = await _service.getDownloadedAudio(ayah.number);
      if (localAudio != null) {
        await _player.setFilePath(localAudio.path);
      } else {
        await _player.setUrl(_service.audioUrl(ayah.number));
      }
      await _player.play();
      setState(() => _currentAyah = ayah.numberInSurah);
      await _service.saveLastRead(surah.number, ayah.numberInSurah);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر تشغيل التلاوة. تحقق من الإنترنت.')),
        );
      }
    }
  }

  Future<void> _toggleBookmark(QuranAyah ayah) async {
    final surah = _selectedSurah;
    if (surah == null) return;
    final value = await _service.toggleBookmark(surah.number, ayah.numberInSurah);
    if (!mounted) return;
    setState(() {
      final key = '${surah.number}:${ayah.numberInSurah}';
      value ? _bookmarks.add(key) : _bookmarks.remove(key);
    });
  }

  void _showSurahPicker() {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * .78,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'ابحث عن سورة',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => (context as Element).markNeedsBuild(),
                ),
              ),
              Expanded(
                child: StatefulBuilder(
                  builder: (context, refresh) => ListView(
                    children: _surahs
                        .where((s) =>
                            s.name.contains(controller.text) ||
                            s.englishName.toLowerCase().contains(
                                  controller.text.toLowerCase(),
                                ) ||
                            s.number.toString() == controller.text)
                        .map((surah) => ListTile(
                              title: Text(surah.name,
                                  textDirection: TextDirection.rtl),
                              subtitle: Text(
                                  '${surah.englishName} • ${surah.numberOfAyahs} آية'),
                              onTap: () {
                                Navigator.pop(context);
                                _loadSurah(surah);
                              },
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _search.dispose();
    _player.dispose();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surah = _selectedSurah;
    final filtered = _ayahs.where((ayah) {
      final q = _search.text.trim();
      return q.isEmpty || ayah.text.contains(q) ||
          ayah.numberInSurah.toString() == q;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('المصحف الشريف'),
        actions: [
          IconButton(
            tooltip: 'اختيار السورة',
            onPressed: _surahs.isEmpty ? null : _showSurahPicker,
            icon: const Icon(Icons.menu_book),
          ),
          PopupMenuButton<int>(
            tooltip: 'حجم الخط',
            onSelected: (value) => setState(() => _fontSize = value),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 22, child: Text('خط أصغر')),
              PopupMenuItem(value: 26, child: Text('خط متوسط')),
              PopupMenuItem(value: 32, child: Text('خط أكبر')),
              PopupMenuItem(value: 38, child: Text('خط كبير جدًا')),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off, size: 44),
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _loadInitial,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    if (surah != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Column(
                          children: [
                            Text(surah.name,
                                style: const TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                                textDirection: TextDirection.rtl),
                            Text(
                                '${surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية'} • ${surah.numberOfAyahs} آية'),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                      child: TextField(
                        controller: _search,
                        decoration: InputDecoration(
                          hintText: 'بحث في آيات السورة أو رقم الآية',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _search.clear();
                              setState(() {});
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final ayah = filtered[index];
                          final key = '${surah!.number}:${ayah.numberInSurah}';
                          final bookmarked = _bookmarks.contains(key);
                          final active = _currentAyah == ayah.numberInSurah;
                          return Card(
                            elevation: active ? 2 : 0,
                            color: active
                                ? Theme.of(context).colorScheme.secondaryContainer
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 17,
                                        child: Text('${ayah.numberInSurah}',
                                            style: const TextStyle(fontSize: 12)),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        tooltip: 'تشغيل تلاوة الآية',
                                        onPressed: () => _playAyah(ayah),
                                        icon: Icon(
                                            active && _playing
                                                ? Icons.pause_circle
                                                : Icons.play_circle_outline,
                                            size: 28),
                                      ),
                                      IconButton(
                                        tooltip: 'حفظ في المفضلة',
                                        onPressed: () => _toggleBookmark(ayah),
                                        icon: Icon(
                                          bookmarked
                                              ? Icons.bookmark
                                              : Icons.bookmark_border,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'تنزيل صوت الآية للعمل دون إنترنت',
                                        onPressed: () async {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('بدأ تنزيل التلاوة...')),
                                          );
                                          try {
                                            await _service.downloadAyahAudio(ayah.number);
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('تم حفظ صوت الآية على الجهاز')),
                                              );
                                            }
                                          } catch (_) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('فشل تنزيل الصوت؛ تحقق من الاتصال')),
                                              );
                                            }
                                          }
                                        },
                                        icon: const Icon(Icons.download_outlined),
                                      ),
                                    ],
                                  ),
                                  SelectableText(
                                    ayah.text,
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      
                                      fontSize: _fontSize.toDouble(),
                                      height: 2.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            TextButton.icon(
                              onPressed: surah!.number > 1
                                  ? () => _loadSurah(_surahs[surah.number - 2])
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                              label: const Text('السورة السابقة'),
                            ),
                            const Spacer(),
                            Text('الآية $_currentAyah'),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: surah.number < _surahs.length
                                  ? () => _loadSurah(_surahs[surah.number])
                                  : null,
                              icon: const Icon(Icons.chevron_left),
                              label: const Text('التالية'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
