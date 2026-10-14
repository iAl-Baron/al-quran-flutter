import 'package:flutter/material.dart';
import 'audio_service.dart';
import 'about_page.dart';
import 'tasbih_page.dart';
import 'prayer_qibla_page.dart';
import 'calendar_page.dart';

class TextsPage extends StatefulWidget {
  final double fontSize;
  final Function(bool) toggleTheme;
  final bool isDarkMode;

  const TextsPage({Key? key, required this.fontSize, required this.toggleTheme, required this.isDarkMode}) : super(key: key);

  @override
  State<TextsPage> createState() => _TextsPageState();
}

class _TextsPageState extends State<TextsPage> {
  String _searchQuery = '';
  String _selectedCategory = 'الكل';

  final List<Map<String, String>> allTexts = [
    // 50 Duas sample
    {'title': 'دعاء كميل بن زياد', 'category': 'أدعية'},
    {'title': 'دعاء التوسل', 'category': 'أدعية'},
    {'title': 'دعاء الندبة', 'category': 'أدعية'},
    {'title': 'دعاء العهد', 'category': 'أدعية'},
    {'title': 'دعاء الصباح', 'category': 'أدعية'},
    {'title': 'دعاء السمات', 'category': 'أدعية'},
    {'title': 'دعاء الجوشن الكبير', 'category': 'أدعية'},
    {'title': 'دعاء الجوشن الصغير', 'category': 'أدعية'},
    {'title': 'دعاء أبي حمزة الثمالي', 'category': 'أدعية'},
    {'title': 'دعاء الافتتاح', 'category': 'أدعية'},
    {'title': 'دعاء مكارم الأخلاق', 'category': 'أدعية'},
    {'title': 'دعاء العشرات', 'category': 'أدعية'},
    {'title': 'دعاء المشلول', 'category': 'أدعية'},
    {'title': 'دعاء صنمي قريش', 'category': 'أدعية'},
    {'title': 'دعاء التوبة', 'category': 'أدعية'},
    {'title': 'دعاء السحر', 'category': 'أدعية'},
    {'title': 'دعاء الحزين', 'category': 'أدعية'},
    {'title': 'دعاء عرفة للإمام الحسين', 'category': 'أدعية'},
    {'title': 'دعاء الفرج', 'category': 'أدعية'},
    {'title': 'دعاء السيفي الصغير', 'category': 'أدعية'},
    // 50 Ziyarats sample
    {'title': 'زيارة عاشوراء', 'category': 'زيارات'},
    {'title': 'زيارة أمين الله', 'category': 'زيارات'},
    {'title': 'زيارة وارث', 'category': 'زيارات'},
    {'title': 'زيارة آل ياسين', 'category': 'زيارات'},
    {'title': 'زيارة الجامعة الكبيرة', 'category': 'زيارات'},
    {'title': 'زيارة الناحية المقدسة', 'category': 'زيارات'},
    {'title': 'زيارة الإمام علي عليه السلام', 'category': 'زيارات'},
    {'title': 'زيارة السيدة فاطمة الزهراء', 'category': 'زيارات'},
    {'title': 'زيارة الإمام الحسين يوم الأربعين', 'category': 'زيارات'},
    {'title': 'زيارة الإمام الرضا عليه السلام', 'category': 'زيارات'},
    {'title': 'زيارة أبوالفضل العباس عليه السلام', 'category': 'زيارات'},
    {'title': 'زيارة الإمام الجواد والإمام الهادي', 'category': 'زيارات'},
    {'title': 'زيارة الإمام العسكري', 'category': 'زيارات'},
    {'title': 'زيارة الإمام المهدي عجل الله فرجه', 'category': 'زيارات'},
    {'title': 'زيارة أئمة البقيع', 'category': 'زيارات'},
    {'title': 'زيارة السيدة زينب عليها السلام', 'category': 'زيارات'},
    {'title': 'زيارة السيدة معصومة عليها السلام', 'category': 'زيارات'},
    {'title': 'زيارة مسلم بن عقيل', 'category': 'زيارات'},
    {'title': 'زيارة الإمام الكاظم عليه السلام', 'category': 'زيارات'},
    {'title': 'زيارة النبي محمد صلى الله عليه وآله', 'category': 'زيارات'},
  ];

  final List<String> bookmarks = [];
  final AudioPlayerService _audioService = AudioPlayerService();

  void _showReciterDialog(String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('اختر القارئ أو المنشد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('الشيخ ميثم التمار'),
                onTap: () {
                  _audioService.selectedReciter = 'الشيخ ميثم التمار';
                  Navigator.pop(context);
                  _playAudio(title);
                },
              ),
              ListTile(
                title: const Text('الحاج باسم الكربلائي'),
                onTap: () {
                  _audioService.selectedReciter = 'الحاج باسم الكربلائي';
                  Navigator.pop(context);
                  _playAudio(title);
                },
              ),
              ListTile(
                title: const Text('الشيخ أباذر الحلواجي'),
                onTap: () {
                  _audioService.selectedReciter = 'الشيخ أباذر الحلواجي';
                  Navigator.pop(context);
                  _playAudio(title);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _playAudio(String title) {
    _audioService.playUrl('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('جاري تشغيل: $title بصوت (${_audioService.selectedReciter})')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTexts = allTexts.where((item) {
      final matchesSearch = item['title']!.contains(_searchQuery);
      final matchesCategory = _selectedCategory == 'الكل' || item['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن والأدعية الشامل'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () => widget.toggleTheme(!widget.isDarkMode),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Text('قائمة الخدمات الشاملة', style: TextStyle(color: Colors.white, fontSize: 22)),
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('مواقيت الصلاة والقبلة'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PrayerQiblaPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('التقويم الهجري والمناسبات'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.radio_button_checked),
              title: const Text('السبحة الإلكترونية'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TasbihPage()));
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'بحث في الأدعية والزيارات...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['الكل', 'أدعية', 'زيارات'].map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTexts.length,
              itemBuilder: (context, index) {
                final item = filteredTexts[index];
                final title = item['title']!;
                final category = item['category']!;
                final isBookmarked = bookmarks.contains(title);
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    title: Text(
                      title,
                      style: TextStyle(fontSize: widget.fontSize, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(category),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.play_arrow, color: Colors.teal),
                          onPressed: () => _showReciterDialog(title),
                        ),
                        IconButton(
                          icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: Colors.amber),
                          onPressed: () {
                            setState(() {
                              if (isBookmarked) {
                                bookmarks.remove(title);
                              } else {
                                bookmarks.add(title);
                              }
                            });
                          },
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'copy') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('تم نسخ: $title')),
                              );
                            } else if (value == 'share') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('مشاركة: $title')),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'copy', child: Text('نسخ النص')),
                            const PopupMenuItem(value: 'share', child: Text('مشاركة')),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
