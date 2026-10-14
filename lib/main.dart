import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuranApp());
}

const forest = Color(0xFF174D3B);
const gold = Color(0xFFD6B36A);
const paper = Color(0xFFF8F6F0);

class QuranApp extends StatefulWidget {
  const QuranApp({super.key});
  @override
  State<QuranApp> createState() => _QuranAppState();
}

class _QuranAppState extends State<QuranApp> {
  bool dark = false;
  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => dark = prefs.getBool('dark_mode') ?? false);
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => dark = !dark);
    await prefs.setBool('dark_mode', dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'القرآن الكريم',
      debugShowCheckedModeBanner: false,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: forest, brightness: Brightness.light),
        scaffoldBackgroundColor: paper,
        appBarTheme: const AppBarTheme(backgroundColor: paper, foregroundColor: forest, centerTitle: true),
        cardTheme: const CardThemeData(color: Colors.white, elevation: 0, margin: EdgeInsets.zero),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: forest, brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF101A16),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF101A16), centerTitle: true),
        cardTheme: const CardThemeData(elevation: 0),
      ),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: MainShell(dark: dark, onToggleTheme: _toggleTheme),
    );
  }
}

class MainShell extends StatefulWidget {
  final bool dark;
  final VoidCallback onToggleTheme;
  const MainShell({super.key, required this.dark, required this.onToggleTheme});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int selected = 0;
  final pages = const [HomePage(), QuranPage(), AdhkarPage(), TasbeehPage(), SettingsPage()];
  final labels = const ['الرئيسية', 'المصحف', 'الأذكار', 'المسبحة', 'الإعدادات'];
  final icons = const [Icons.home_rounded, Icons.menu_book_rounded, Icons.auto_awesome_rounded, Icons.radio_button_checked, Icons.settings_rounded];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: selected, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (i) => setState(() => selected = i),
        destinations: List.generate(labels.length, (i) => NavigationDestination(icon: Icon(icons[i]), label: labels[i])),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CustomScrollView(slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        sliver: SliverList.list(children: [
          Row(children: [
            Container(width: 46, height: 46, decoration: BoxDecoration(color: forest, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.auto_stories_rounded, color: gold, size: 27)),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('السلام عليكم ورحمة الله', style: TextStyle(fontSize: 14, color: Colors.grey)),
              SizedBox(height: 3),
              Text('القرآن الكريم', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            ])),
            IconButton(tooltip: 'الإعدادات', onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
          ]),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF174D3B), Color(0xFF23664D)], begin: Alignment.topRight, end: Alignment.bottomLeft),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [BoxShadow(color: forest.withValues(alpha: .16), blurRadius: 22, offset: const Offset(0, 9))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.nights_stay_rounded, color: gold),
                SizedBox(width: 8),
                Text('وَلَقَدْ يَسَّرْنَا الْقُرْآنَ لِلذِّكْرِ', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ]),
              const SizedBox(height: 16),
              const Text('رفيقك اليومي مع كتاب الله', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('اقرأ بتدبّر، وداوم على وردك، واجعل للقرآن مكانًا في يومك.', style: TextStyle(color: Colors.white70, height: 1.7)),
              const SizedBox(height: 20),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: forest, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13)),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QuranPage())),
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('ابدأ القراءة', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ]),
          ),
          const SizedBox(height: 22),
          const Text('مساحتك الإيمانية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.55,
            children: const [
              _Shortcut(icon: Icons.menu_book_rounded, title: 'المصحف الشريف', subtitle: 'السور والآيات'),
              _Shortcut(icon: Icons.spa_rounded, title: 'الأذكار', subtitle: 'أذكار يومية'),
              _Shortcut(icon: Icons.radio_button_checked, title: 'المسبحة', subtitle: 'ورد التسبيح'),
              _Shortcut(icon: Icons.bookmark_outline_rounded, title: 'المفضلة', subtitle: 'مواضعك المحفوظة'),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: cs.outlineVariant)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Icon(Icons.wb_twilight_rounded, color: gold), SizedBox(width: 8), Text('ورد اليوم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
              SizedBox(height: 12),
              Text('«إِنَّ مَعَ الْعُسْرِ يُسْرًا»', textAlign: TextAlign.center, style: TextStyle(fontSize: 25, height: 1.8, fontWeight: FontWeight.w600)),
              SizedBox(height: 6),
              Text('سورة الشرح · الآية 6', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              SizedBox(height: 8),
              Text('ملاحظة: الآية المعروضة هنا ثابتة في النموذج الأولي، وليست اختيارًا يوميًا متغيرًا بعد.', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ]),
          ),
          const SizedBox(height: 12),
          const Text('التاريخ الهجري والميلادي ومواقيت الصلاة ستُربط بمصدر بيانات موثوق في مرحلة الخدمات.', style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.6)),
        ]),
      ),
    ]);
  }
}

class _Shortcut extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Shortcut({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: gold, size: 25),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ]),
    );
  }
}

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});
  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  List<dynamic> chapters = [];
  bool loading = true;
  String? error;
  final search = TextEditingController();

  @override
  void initState() { super.initState(); loadChapters(); }
  @override
  void dispose() { search.dispose(); super.dispose(); }

  Future<void> loadChapters() async {
    setState(() { loading = true; error = null; });
    try {
      final uri = Uri.parse('https://api.quran.com/api/v4/chapters?language=ar');
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) throw Exception('تعذر جلب قائمة السور (HTTP ${response.statusCode})');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final result = (data['chapters'] as List<dynamic>);
      if (mounted) setState(() { chapters = result; loading = false; });
    } catch (_) {
      if (mounted) setState(() { loading = false; error = 'تعذر الاتصال بمصدر السور. تحقق من الإنترنت ثم أعد المحاولة.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = chapters.where((c) {
      final name = (c['name_arabic'] ?? '').toString();
      final id = (c['id'] ?? '').toString();
      return name.contains(search.text.trim()) || id.contains(search.text.trim());
    }).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('المصحف الشريف', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        TextField(controller: search, onChanged: (_) => setState(() {}),
          decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'ابحث عن سورة أو رقمها', filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none))),
        const SizedBox(height: 12),
        Expanded(child: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.wifi_off_rounded, size: 42), const SizedBox(height: 12), Text(error!, textAlign: TextAlign.center), const SizedBox(height: 12), FilledButton(onPressed: loadChapters, child: const Text('إعادة المحاولة'))]))
            : ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final c = filtered[index] as Map<String, dynamic>;
                return ListTile(
                  leading: Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: forest.withValues(alpha: .09), borderRadius: BorderRadius.circular(13)), child: Text('${c['id']}', style: const TextStyle(color: forest, fontWeight: FontWeight.bold))),
                  title: Text('${c['name_arabic'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  subtitle: Text('${c['verses_count'] ?? '—'} آية · ${c['revelation_place'] == 'makkah' ? 'مكية' : 'مدنية'}'),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SurahPage(chapterId: c['id'] as int, name: c['name_arabic']?.toString() ?? 'السورة'))),
                );
              },
            )),
      ])),
    );
  }
}

class SurahPage extends StatefulWidget {
  final int chapterId;
  final String name;
  const SurahPage({super.key, required this.chapterId, required this.name});
  @override
  State<SurahPage> createState() => _SurahPageState();
}

class _SurahPageState extends State<SurahPage> {
  List<dynamic> verses = [];
  bool loading = true;
  String? error;

  @override
  void initState() { super.initState(); loadVerses(); }

  Future<void> loadVerses() async {
    try {
      final uri = Uri.https('api.quran.com', '/api/v4/verses/by_chapter/${widget.chapterId}', {
        'language': 'ar', 'fields': 'text_uthmani', 'per_page': '300'
      });
      final response = await http.get(uri).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (mounted) setState(() { verses = data['verses'] as List<dynamic>; loading = false; });
    } catch (_) {
      if (mounted) setState(() { loading = false; error = 'تعذر تحميل الآيات. تأكد من الاتصال بالإنترنت.'; });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.name, style: const TextStyle(fontWeight: FontWeight.bold))),
    body: loading ? const Center(child: CircularProgressIndicator())
      : error != null ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(error!), const SizedBox(height: 12), FilledButton(onPressed: () { setState(() { loading = true; error = null; }); loadVerses(); }, child: const Text('إعادة المحاولة'))]))
      : ListView(padding: const EdgeInsets.all(18), children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: forest, borderRadius: BorderRadius.circular(20)), child: Text(widget.name, textAlign: TextAlign.center, style: const TextStyle(color: gold, fontSize: 25, fontWeight: FontWeight.bold))),
        const SizedBox(height: 14),
        if (widget.chapterId != 1 && widget.chapterId != 9)
          const Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', textAlign: TextAlign.center, style: TextStyle(fontSize: 23, height: 2.2)),
        const SizedBox(height: 10),
        SelectableText(
          verses.map((v) => '${v['text_uthmani'] ?? ''} ۝${v['verse_number'] ?? ''}').join('  '),
          textAlign: TextAlign.justify,
          style: const TextStyle(fontSize: 25, height: 2.15),
        ),
        const SizedBox(height: 18),
        const Text('المصدر: Quran.com API. يلزم التحقق من شروط الاستخدام وإضافة نسخة بيانات محلية موثوقة قبل اعتماد وضع عدم الاتصال.', style: TextStyle(color: Colors.grey, fontSize: 11, height: 1.5)),
      ]),
  );
}

class AdhkarPage extends StatelessWidget {
  const AdhkarPage({super.key});
  static const adhkar = [
    ('أذكار الصباح', 'أصبحنا وأصبح الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له.'),
    ('ذكر التسبيح', 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ'),
    ('ذكر الاستغفار', 'أستغفر الله وأتوب إليه'),
    ('الصلاة على النبي ﷺ', 'اللهم صلِّ وسلم على نبينا محمد'),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('الأذكار')),
    body: ListView.separated(padding: const EdgeInsets.all(16), itemCount: adhkar.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => Card(
        child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(adhkar[i].$1, style: const TextStyle(fontWeight: FontWeight.bold, color: gold)),
          const SizedBox(height: 10),
          Text(adhkar[i].$2, style: const TextStyle(fontSize: 20, height: 1.8)),
          const SizedBox(height: 8),
          const Text('هذه قائمة أولية؛ يلزم توثيق كل ذكر ومصدره وعدد تكراره قبل الإصدار النهائي.', style: TextStyle(fontSize: 11, color: Colors.grey)),
        ])),
      )),
  );
}

class TasbeehPage extends StatefulWidget {
  const TasbeehPage({super.key});
  @override
  State<TasbeehPage> createState() => _TasbeehPageState();
}

class _TasbeehPageState extends State<TasbeehPage> {
  int count = 0;
  int target = 33;
  String phrase = 'سُبْحَانَ اللَّهِ';

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) setState(() { count = p.getInt('tasbeeh_count') ?? 0; target = p.getInt('tasbeeh_target') ?? 33; phrase = p.getString('tasbeeh_phrase') ?? 'سُبْحَانَ اللَّهِ'; });
  }
  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('tasbeeh_count', count);
    await p.setInt('tasbeeh_target', target);
    await p.setString('tasbeeh_phrase', phrase);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('المسبحة الإلكترونية')),
    body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      DropdownButton<String>(value: phrase, isExpanded: true, items: const [
        DropdownMenuItem(value: 'سُبْحَانَ اللَّهِ', child: Text('سُبْحَانَ اللَّهِ')),
        DropdownMenuItem(value: 'الْحَمْدُ لِلَّهِ', child: Text('الْحَمْدُ لِلَّهِ')),
        DropdownMenuItem(value: 'اللَّهُ أَكْبَرُ', child: Text('اللَّهُ أَكْبَرُ')),
        DropdownMenuItem(value: 'أَسْتَغْفِرُ اللَّهَ', child: Text('أَسْتَغْفِرُ اللَّهَ')),
      ], onChanged: (v) { if (v != null) setState(() => phrase = v); _save(); }),
      const SizedBox(height: 28),
      Text(phrase, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      const SizedBox(height: 28),
      InkWell(
        borderRadius: BorderRadius.circular(120),
        onTap: () { setState(() => count++); _save(); },
        child: Container(width: 220, height: 220, decoration: BoxDecoration(shape: BoxShape.circle, color: forest, border: Border.all(color: gold, width: 5), boxShadow: [BoxShadow(color: forest.withValues(alpha: .2), blurRadius: 24, offset: const Offset(0, 8))]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('$count', style: const TextStyle(fontSize: 54, color: Colors.white, fontWeight: FontWeight.bold)),
          Text('من $target', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          const Text('اضغط للتسبيح', style: TextStyle(color: gold)),
        ])),
      ),
      const SizedBox(height: 24),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        OutlinedButton.icon(onPressed: () { setState(() => count = 0); _save(); }, icon: const Icon(Icons.restart_alt), label: const Text('تصفير العداد')),
        const SizedBox(width: 10),
        OutlinedButton.icon(onPressed: () async { final v = await showDialog<int>(context: context, builder: (ctx) { final c = TextEditingController(text: '$target'); return AlertDialog(title: const Text('العدد المستهدف'), content: TextField(controller: c, keyboardType: TextInputType.number), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(ctx, int.tryParse(c.text)), child: const Text('حفظ'))]); }); if (v != null && v > 0) { setState(() => target = v); _save(); } }, icon: const Icon(Icons.tune), label: const Text('تحديد الهدف')),
      ]),
      const SizedBox(height: 12),
      const Text('يُحفظ العداد على هذا الجهاز تلقائيًا.', style: TextStyle(color: Colors.grey)),
    ]))),
  );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final shell = context.findAncestorStateOfType<_MainShellState>();
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: SwitchListTile(
          secondary: const Icon(Icons.dark_mode_outlined),
          title: const Text('الوضع الليلي'),
          subtitle: const Text('تغيير مظهر التطبيق'),
          value: shell?.widget.dark ?? false,
          onChanged: (_) => shell?.widget.onToggleTheme(),
        )),
        const Card(child: ListTile(leading: Icon(Icons.language), title: Text('اللغة'), subtitle: Text('العربية — اللغات الأخرى لاحقًا'))),
        const Card(child: ListTile(leading: Icon(Icons.privacy_tip_outlined), title: Text('الخصوصية'), subtitle: Text('لا يُطلب الموقع في هذا الإصدار الأولي'))),
        const Card(child: ListTile(leading: Icon(Icons.info_outline), title: Text('حول التطبيق'), subtitle: Text('نسخة تأسيسية قابلة للتطوير — ليست إصدارًا نهائيًا للنشر'))),
      ]),
    );
  }
}
